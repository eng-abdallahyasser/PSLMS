import 'dart:io';

import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/instructor/courses/content/data/datasources/provider_upload_client.dart';
import 'package:lms/features/instructor/courses/content/data/models/upload_session_model.dart';
import 'package:lms/features/shared/data/models/content_model.dart';

abstract class ContentRemoteDataSource {
  /// Get all content items for a course (instructor).
  Future<List<ContentModel>> getContents(String courseId);

  /// Upload a new content file for a course using the direct-upload flow:
  /// init session → upload straight to provider → complete (instructor).
  Future<ContentModel> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
    bool? isPreview,
  });

  /// Returns resume/progress status of an upload session (instructor).
  Future<UploadStatus> getUploadStatus(String sessionId);

  /// Cancels an in-progress upload session and releases reserved quota.
  Future<void> abortUpload(String sessionId);

  /// Reorder content items within a course (instructor).
  Future<void> reorderContent({
    required String courseId,
    required List<String> contentIds,
  });

  /// Update a content item's metadata (instructor).
  Future<ContentModel> updateContent({
    required String courseId,
    required String contentId,
    String? title,
    String? description,
    bool? isPreview,
  });

  /// Delete a content item from a course (instructor).
  Future<void> deleteContent({
    required String courseId,
    required String contentId,
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

  const ContentsResponse({required this.data, required this.totalItems});
  final List<ContentModel> data;
  final int totalItems;
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {

  ContentRemoteDataSourceImpl({
    required this.apiClient,
    ProviderUploadClient? providerUploadClient,
  }) : _providerUploadClient =
            providerUploadClient ?? ProviderUploadClientImpl();
  final ApiClient apiClient;
  final ProviderUploadClient _providerUploadClient;

  @override
  Future<List<ContentModel>> getContents(String courseId) async {
    try {
      final body = await apiClient.get(
        '/instructor/courses/$courseId/content',
      );
      final dataList = (body['data'] as List<dynamic>)
          .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ContentModel> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
    bool? isPreview,
  }) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final fileSize = await _fileSize(filePath);

    try {
      // 1) Reserve quota & get direct-upload credentials.
      final initBody = await apiClient.post(
        '/instructor/courses/$courseId/content/upload-session',
        data: {
          'fileName': fileName,
          'fileSize': '$fileSize',
          'mimeType': _mimeTypeOf(fileName),
          'title': title,
          'description': ?description,
          'isPreview': ?isPreview,
        },
      );
      final session = UploadSession.fromJson(initBody);
      if (session.sessionId.isEmpty || session.uploadUrl.isEmpty) {
        throw const ServerException(
          message: 'Invalid upload session response',
          statusCode: 500,
        );
      }

      // 2) Upload straight to the storage provider.
      final result = await _providerUploadClient.upload(
        session: session,
        filePath: filePath,
      );

      // 3) Finalize: validate, create CourseContent record, commit quota.
      final body = await apiClient.post(
        '/instructor/courses/$courseId/content/complete-upload',
        data: {
          'sessionId': session.sessionId,
          'title': title,
          'description': ?description,
          'isPreview': ?isPreview,
          'cloudinaryResult': result.toJson(),
        },
      );
      return ContentModel.fromJson(body);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UploadStatus> getUploadStatus(String sessionId) async {
    try {
      final body = await apiClient.get('/uploads/session/$sessionId/status');
      return UploadStatus.fromJson(body);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> abortUpload(String sessionId) async {
    try {
      await apiClient.delete('/uploads/session/$sessionId');
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  Future<int> _fileSize(String filePath) async {
    try {
      final file = await File(filePath).exists();
      if (file) {
        return await File(filePath).length();
      }
    } catch (_) {}
    return 0;
  }

  String _mimeTypeOf(String fileName) {
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'mp4' || 'mov' || 'avi' || 'mkv' => 'video/$ext',
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'doc' => 'application/msword',
      'docx' =>
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'ppt' => 'application/vnd.ms-powerpoint',
      'pptx' =>
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'zip' => 'application/zip',
      _ => 'application/octet-stream',
    };
  }

  @override
  Future<ContentsResponse> getMyCourseContents(
    String courseId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final body = await apiClient.get(
        '/learner/my-courses/$courseId/content',
        queryParameters: {'page': page, 'limit': limit},
      );
      final dataList = (body['data'] as List<dynamic>)
          .map((e) => ContentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final totalItems = body['meta']?['totalItems'] as int? ??
          body['totalItems'] as int? ??
          dataList.length;
      return ContentsResponse(data: dataList, totalItems: totalItems);
    } on ApiException catch (e) {
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
      return ContentModel.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> reorderContent({
    required String courseId,
    required List<String> contentIds,
  }) async {
    try {
      await apiClient.patch(
        '/instructor/courses/$courseId/content/reorder',
        data: {'contentIds': contentIds, 'videoIds': contentIds},
      );
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ContentModel> updateContent({
    required String courseId,
    required String contentId,
    String? title,
    String? description,
    bool? isPreview,
  }) async {
    try {
      final response = await apiClient.patch(
        '/instructor/courses/$courseId/content/$contentId',
        data: {
          'title': ?title,
          'description': ?description,
          'isPreview': ?isPreview,
        },
      );
      return ContentModel.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteContent({
    required String courseId,
    required String contentId,
  }) async {
    try {
      await apiClient.delete(
        '/instructor/courses/$courseId/content/$contentId',
      );
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