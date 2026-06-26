
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/auth/data/models/login_response.dart';
import 'package:lms/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  });

  Future<UserModel> getCurrentUser();

  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String password,
  });

  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  AuthRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      log(name: 'Auth Remote Data Source',  '=== Login Response ===');
      log(name: 'Auth Remote Data Source',  'Status: ${response.statusCode}');
      log(name: 'Auth Remote Data Source',  'Headers: ${response.headers}');
      log(name: 'Auth Remote Data Source',  'Body: ${response.data}');
      log(name: 'Auth Remote Data Source',  '=== End ===');
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/users/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await apiClient.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': password,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      return data['accessToken'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ServerException _handleDioError(DioException e) {
    log(name: 'Auth Remote Data Source','=== Dio Error ===');
    log(name: 'Auth Remote Data Source','Type: ${e.type}');
    log(name: 'Auth Remote Data Source','Message: ${e.message}');
    log(name: 'Auth Remote Data Source','Underlying Error: ${e.error}');
    log(name: 'Auth Remote Data Source','Underlying Type: ${e.error.runtimeType}');
    log(name: 'Auth Remote Data Source','Status: ${e.response?.statusCode}');
    log(name: 'Auth Remote Data Source','Response Data: ${e.response?.data}');
    log(name: 'Auth Remote Data Source','=== End ===');
    final error = e.error;
    if (error is ServerException) return error;
    if (error is AuthException) {
      return ServerException(
        message: error.message,
        statusCode: error.statusCode,
      );
    }
    return ServerException(
      message: e.message ?? 'An unexpected error occurred',
      statusCode: e.response?.statusCode,
    );
  }
}
