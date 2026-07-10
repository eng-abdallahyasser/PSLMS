import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/shared/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
  });

  Future<void> updatePreferences({
    String? lang,
    String? mode,
  });

  Future<String> uploadAvatar(String filePath);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {

  ProfileRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await apiClient.get('/profile/me');
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;

      final response = await apiClient.patch('/profile/me', data: body);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> updatePreferences({
    String? lang,
    String? mode,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (lang != null) body['lang'] = lang;
      if (mode != null) body['mode'] = mode;

      await apiClient.patch('/profile/me/preferences', data: body);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await apiClient.post(
        '/profile/me/avatar',
        data: formData,
      );
      final data = response.data as Map<String, dynamic>;
      return data['avatarUrl'] as String? ?? data['avatar_url'] as String? ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(DioException e) {
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
