import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:lms/core/constants/app_constants.dart';
import 'package:lms/core/errors/exceptions.dart';

class ApiClient {

  ApiClient({
    String? baseUrl,
    String? Function()? tokenProvider,
    Future<String?> Function()? onTokenRefresh,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(tokenProvider),
      _ErrorInterceptor(_dio, onTokenRefresh),
    ]);
  }
  late final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('[API] GET $path');
    final response = await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    log('[API] GET $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('[API] POST $path');
    final response = await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    log('[API] POST $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('[API] PUT $path');
    final response = await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    log('[API] PUT $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('[API] PATCH $path');
    final response = await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    log('[API] PATCH $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('[API] DELETE $path');
    final response = await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    log('[API] DELETE $path: ${response.statusCode} ${response.data}');
    return response;
  }
}

class _AuthInterceptor extends Interceptor {

  _AuthInterceptor(this._tokenProvider);
  final String? Function()? _tokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  _ErrorInterceptor(this._dio, this._refreshTokenProvider);

  final Dio _dio;
  final Future<String?> Function()? _refreshTokenProvider;
  Completer<String?>? _refreshCompleter;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    log('[API] $path: $statusCode $data');

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const NetworkException(),
          ),
        );
        return;
      case DioExceptionType.badResponse:
        final message = data?['message'] as String? ?? 'Something went wrong';
        final errorCode = data?['errorCode'] as String?;

        log('[DEBUG] onError path=$path status=$statusCode hadToken=${err.requestOptions.headers.containsKey("Authorization")} authHeader=${err.requestOptions.headers['Authorization']}');

        if (statusCode == 401 || statusCode == 403) {
          final isAuthPath = path.startsWith('/auth/');
          log('[DEBUG] 401/403 branch: isAuthPath=$isAuthPath refreshProvider=${_refreshTokenProvider != null} retried=${err.requestOptions.extra['_retried']}');
          if (isAuthPath || _refreshTokenProvider == null) {
            log('[DEBUG] Rejecting immediately with AuthException: message=$message errorCode=$errorCode');
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: AuthException(message: message, statusCode: statusCode, errorCode: errorCode),
              ),
            );
            return;
          }

          if (err.requestOptions.extra['_retried'] == true) {
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: const AuthException(message: 'Session expired', statusCode: 401),
              ),
            );
            return;
          }

          try {
            final newToken = await _getRefreshedToken();
            if (newToken != null && newToken.isNotEmpty) {
              err.requestOptions.extra['_retried'] = true;
              final response = await _dio.fetch(err.requestOptions);
              handler.resolve(response);
              return;
            }
          } catch (_) {
          }

          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: const AuthException(message: 'Session expired', statusCode: 401),
            ),
          );
          return;
        }

        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ServerException(
              message: message,
              statusCode: statusCode,
              data: data,
            ),
          ),
        );
        return;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        handler.next(err);
    }
  }

  Future<String?> _getRefreshedToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<String?>();
    try {
      final token = await _refreshTokenProvider!();
      _refreshCompleter!.complete(token);
      return token;
    } catch (e) {
      _refreshCompleter!.complete(null);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }
}
