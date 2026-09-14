import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/core/utils/avatar_url.dart';
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
      final data = response;
      return ProfileModel.fromJson(data);
    } on ApiException catch (e) {
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
      return ProfileModel.fromJson(response);
    } on ApiException catch (e) {
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
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final data = await apiClient.uploadFile(
        '/profile/me/avatar',
        filePath: filePath,
        fieldName: 'file',
      );
      return AvatarUrl.resolve(
            data['profileImageUrl'] as String? ??
                data['profile_image_url'] as String? ??
                data['avatarUrl'] as String? ??
                data['avatar_url'] as String?,
          ) ??
          '';
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(ApiException e) {
    return ServerException(
      message: e.message,
      statusCode: e.statusCode,
    );
  }
}
