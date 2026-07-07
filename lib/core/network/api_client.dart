import 'dart:developer' as developer;

import 'package:dio/dio.dart';
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
      _ErrorInterceptor(),
    ]);
  }
  late final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    developer.log('GET $path');
    final response = await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    developer.log('GET $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    developer.log('POST $path');
    final response = await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    developer.log('POST $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    developer.log('PUT $path');
    final response = await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    developer.log('PUT $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    developer.log('PATCH $path');
    final response = await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    developer.log('PATCH $path: ${response.statusCode} ${response.data}');
    return response;
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    developer.log('DELETE $path');
    final response = await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    developer.log('DELETE $path: ${response.statusCode} ${response.data}');
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
