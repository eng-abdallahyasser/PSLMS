
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/auth/data/models/device_info_model.dart';
import 'package:lms/features/auth/data/models/login_response.dart';
import 'package:lms/features/auth/data/models/user_model.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login({
    required String email,
    required String password,
    required String client,
    String? deviceToken,
    DeviceInfo? deviceInfo,
  });

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobileNumber,
    required String password,
    required String role,
    String? client,
  });

  Future<UserModel> getCurrentUser();

  Future<void> logout();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String token,
    required String password,
  });

  Future<LoginResponse> refreshToken(String refreshToken);

  Future<void> verifyEmail({
    required String email,
    required String otp,
  });

  Future<void> sendOtp({
    required String email,
  });

  Future<void> sendMobileOtp({
    required String mobileNumber,
    required String client,
  });

  Future<LoginResponse> verifyMobileOtp({
    required String mobileNumber,
    required String otp,
    required String client,
    String? deviceToken,
    DeviceInfo? deviceInfo,
  });

  Future<void> completeRegistration({
    required String tempToken,
    String? role,
    String? client,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  AuthRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
    required String client,
    String? deviceToken,
    DeviceInfo? deviceInfo,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'client': client,
          'deviceToken': ?deviceToken,
          if (deviceInfo != null) 'deviceInfo': deviceInfo.toJson(),
        },
      );
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
    required String mobileNumber,
    required String password,
    required String role,
    String? client,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'mobileNumber': mobileNumber,
          'password': password,
          'role': role,
          'client': ?client,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return UserModel(
        id: data['id'] as String? ?? '',
        email: data['email'] as String? ?? email,
        firstName: data['firstName'] as String? ?? data['first_name'] as String? ?? firstName,
        lastName: data['lastName'] as String? ?? data['last_name'] as String? ?? lastName,
        role: data['role'] != null
            ? UserRole.fromString(data['role'] as String)
            : UserRole.fromString(role),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/profile/me');
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
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      await apiClient.post(
        '/auth/verify-email',
        data: {
          'email': email,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> sendOtp({
    required String email,
  }) async {
    try {
      await apiClient.post(
        '/auth/send-otp',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> sendMobileOtp({
    required String mobileNumber,
    required String client,
  }) async {
    try {
      await apiClient.post(
        '/auth/send-mobile-otp',
        data: {
          'mobileNumber': mobileNumber,
          'client': client,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<LoginResponse> verifyMobileOtp({
    required String mobileNumber,
    required String otp,
    required String client,
    String? deviceToken,
    DeviceInfo? deviceInfo,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/verify-mobile-otp',
        data: {
          'mobileNumber': mobileNumber,
          'otp': otp,
          'client': client,
          'deviceToken': ?deviceToken,
          if (deviceInfo != null) 'deviceInfo': deviceInfo.toJson(),
        },
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> completeRegistration({
    required String tempToken,
    String? role,
    String? client,
  }) async {
    try {
      await apiClient.post(
        '/auth/complete-registration',
        data: {
          'tempToken': tempToken,
          'role': ?role,
          'client': ?client,
        },
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    final error = e.error;
    log('[DEBUG] _handleDioError: errorType=${error.runtimeType} message=${error is AuthException ? error.message : error is ServerException ? error.message : e.message}');
    if (error is ServerException) throw error;
    if (error is AuthException) throw error;
    if (error is NetworkException) throw error;
    throw ServerException(
      message: e.message ?? 'An unexpected error occurred',
      statusCode: e.response?.statusCode,
    );
  }
}
