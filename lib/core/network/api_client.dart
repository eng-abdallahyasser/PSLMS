import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lms/core/constants/app_constants.dart';
import 'package:lms/core/errors/exceptions.dart';

/// Centralized HTTP client using Dio with interceptors for auth, logging,
/// and error handling.
class ApiClient {

  ApiClient({
    String? baseUrl,
    String? Function()? tokenProvider,
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
      _LogInterceptor(),
      _ErrorInterceptor(),
    ]);
  }
  late final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
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

/// Interceptor that logs all requests and responses to the debug console.
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('─── HTTP ─── ${options.method} ${options.path} ───')
      ..writeln('Headers: ${options.headers}')
      ..writeln('Query: ${options.queryParameters}');
    if (options.data != null) {
      buffer.writeln('Body: ${options.data}');
    }
    debugPrint(buffer.toString());
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('─── RESPONSE ─── ${response.statusCode} ${response.requestOptions.path} ───')
      ..writeln('Data: ${response.data}');
    debugPrint(buffer.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('─── ERROR ─── ${err.response?.statusCode} ${err.requestOptions.path} ───')
      ..writeln('Type: ${err.type}')
      ..writeln('Message: ${err.message}');
    if (err.response?.data != null) {
      buffer.writeln('Data: ${err.response?.data}');
    }
    debugPrint(buffer.toString());
    handler.next(err);
  }
}

/// Interceptor that translates DioExceptions into app-specific exceptions.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
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
        final statusCode = err.response?.statusCode;
        final message = err.response?.data?['message'] as String? ??
            'Something went wrong';

        if (statusCode == 401 || statusCode == 403) {
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: AuthException(message: message, statusCode: statusCode),
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
              data: err.response?.data,
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
}
