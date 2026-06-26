import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/contents/data/models/content_model.dart';

abstract class ContentRemoteDataSource {
  /// Get all content items for a course.
  Future<List<ContentModel>> getContents(String courseId);

  /// Upload a new content file for a course using multipart/form-data.
  Future<ContentModel> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
  });
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final ApiClient apiClient;

  ContentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ContentModel>> getContents(String courseId) async {
    try {
      final response = await apiClient.get(
        '/courses/$courseId/contents',
      );
      final body = response.data as Map<String, dynamic>;
      final dataList = (body['data'] as List<dynamic>)
          .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ContentModel> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'title': title,
        if (description != null) 'description': description,
      });

      final response = await apiClient.post(
        '/courses/$courseId/contents',
        data: formData,
        // Dio auto-detects FormData and sets multipart/form-data with boundary
      );
      return ContentModel.fromJson(response.data as Map<String, dynamic>);
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
