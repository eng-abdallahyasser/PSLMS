import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/contents/data/models/content_model.dart';

abstract class ContentRemoteDataSource {
  /// Get all content items for a course (instructor).
  Future<List<ContentModel>> getContents(String courseId);

  /// Upload a new content file for a course using multipart/form-data (instructor).
  Future<ContentModel> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
  });

  /// Get paginated content for an enrolled course (learner).
  Future<ContentsResponse> getMyCourseContents(
    String courseId, {
    int page = 1,
    int limit = 10,
  });

  /// Get a single content item detail for an enrolled course (learner).
  Future<ContentModel> getMyContentDetail(
    String courseId,
    String contentId,
  );
}

class ContentsResponse {
  final List<ContentModel> data;
  final int totalItems;

  const ContentsResponse({required this.data, required this.totalItems});
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final ApiClient apiClient;

  ContentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ContentModel>> getContents(String courseId) async {
    try {
      final response = await apiClient.get(
        '/instructor/courses/$courseId/content',
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
        '/instructor/courses/$courseId/content',
        data: formData,
        // Dio auto-detects FormData and sets multipart/form-data with boundary
      );
      return ContentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ContentsResponse> getMyCourseContents(
    String courseId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        '/learner/my-courses/$courseId/content',
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = response.data as Map<String, dynamic>;
      final dataList = (body['data'] as List<dynamic>)
          .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final totalItems = body['meta']?['totalItems'] as int? ??
          body['totalItems'] as int? ??
          dataList.length;
      return ContentsResponse(data: dataList, totalItems: totalItems);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ContentModel> getMyContentDetail(
    String courseId,
    String contentId,
  ) async {
    try {
      final response = await apiClient.get(
        '/learner/my-courses/$courseId/content/$contentId',
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
