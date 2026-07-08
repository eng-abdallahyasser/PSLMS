import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:lms/core/constants/app_constants.dart';
import 'package:lms/core/errors/exceptions.dart';

/// Centralized HTTP client using Dio with interceptors for auth, logging,
/// and error handling.
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
    log('GET $path');
    final response = await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    log('GET $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('POST $path');
    final response = await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    log('POST $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('PUT $path');
    final response = await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    log('PUT $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('PATCH $path');
    final response = await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    log('PATCH $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    log('DELETE $path');
    final response = await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    log('DELETE $path: ${response.statusCode} ${response.data}');
    return response;
  }
}

/// Interceptor that attaches the auth token to requests.
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

/// Interceptor that translates DioExceptions into app-specific exceptions
/// and handles automatic token refresh on 401/403 responses.
class _ErrorInterceptor extends Interceptor {
  _ErrorInterceptor(this._dio, this._refreshTokenProvider);

  final Dio _dio;
  final Future<String?> Function()? _refreshTokenProvider;
  Future<String?>? _refreshFuture;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    log('$path: $statusCode $data');

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
        final message = data?['message'] as String? ??
            'Something went wrong';

        if (statusCode == 401 || statusCode == 403) {
          // Don't retry if the failing request is the refresh endpoint itself
          if (path.contains('/auth/refresh') || _refreshTokenProvider == null) {
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                error: AuthException(message: message, statusCode: statusCode),
              ),
            );
            return;
          }

          // Attempt token refresh — concurrent 401s share the same refresh call
          try {
            final newToken = await _getRefreshedToken();
            if (newToken != null && newToken.isNotEmpty) {
              final response = await _dio.fetch(err.requestOptions);
              handler.resolve(response);
              return;
            }
          } catch (_) {
            // Refresh threw — fall through to reject
          }

          // Refresh failed — propagate auth error (triggers re-login)
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: AuthException(
                message: 'Session expired',
                statusCode: statusCode,
              ),
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

  /// Ensures only one refresh call runs at a time; concurrent callers
  /// share the same in-flight request.
  Future<String?> _getRefreshedToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture;
    }
    _refreshFuture = _refreshTokenProvider!();
    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }
}
