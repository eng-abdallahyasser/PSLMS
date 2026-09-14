
import 'dart:developer';
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
      return LoginResponse.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
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
      final data = response;
      return UserModel(
        id: data['id'] as String? ?? '',
        email: data['email'] as String? ?? email,
        firstName: data['firstName'] as String? ?? data['first_name'] as String? ?? firstName,
        lastName: data['lastName'] as String? ?? data['last_name'] as String? ?? lastName,
        role: data['role'] != null
            ? UserRole.fromString(data['role'] as String)
            : UserRole.fromString(role),
      );
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/profile/me');
      return UserModel.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout');
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post('/auth/forgot-password', data: {'email': email});
    } on ApiException catch (e) {
      throw _handleError(e);
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
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        skipAuthRefresh: true,
      );
      return LoginResponse.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
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
    } on ApiException catch (e) {
      throw _handleError(e);
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
    } on ApiException catch (e) {
      throw _handleError(e);
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
    } on ApiException catch (e) {
      throw _handleError(e);
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
      return LoginResponse.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
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
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  Never _handleError(ApiException e) {
    log('[DEBUG] _handleError: message=${e.message} statusCode=${e.statusCode} errorCode=${e.code}');
    if (e.statusCode == 401 || e.statusCode == 403) {
      throw AuthException(
        message: e.message,
        statusCode: e.statusCode,
        errorCode: e.code,
      );
    }
    throw ServerException(message: e.message, statusCode: e.statusCode);
  }
}
