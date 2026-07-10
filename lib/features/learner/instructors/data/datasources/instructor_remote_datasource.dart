import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/shared/data/models/course_model.dart';
import 'package:lms/features/learner/instructors/data/models/instructor_profile_model.dart';
import 'package:lms/features/learner/instructors/data/models/invitation_info_model.dart';

class PaginatedInstructors {

  const PaginatedInstructors({required this.data, required this.totalItems});
  final List<InstructorProfileModel> data;
  final int totalItems;
}

abstract class InstructorRemoteDataSource {
  Future<PaginatedInstructors> searchInstructors({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<InstructorProfileModel> getInstructorProfile(String id);

  Future<void> requestToJoin(String instructorId);

  Future<List<InstructorProfileModel>> getMyInstructors();

  Future<List<CourseModel>> getInstructorCourses(String instructorId);

  Future<InvitationInfoModel> getInvitationInfo(String token);

  Future<void> acceptInvitation(String token);
}

class InstructorRemoteDataSourceImpl implements InstructorRemoteDataSource {

  InstructorRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<PaginatedInstructors> searchInstructors({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.get(
        '/learner/instructors',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final dataList = (body['data'] as List<dynamic>)
          .map((e) => InstructorProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final totalItems = body['meta']?['totalItems'] as int? ??
          body['totalItems'] as int? ??
          dataList.length;
      return PaginatedInstructors(data: dataList, totalItems: totalItems);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<InstructorProfileModel> getInstructorProfile(String id) async {
    try {
      final response = await apiClient.get('/learner/instructors/$id');
      return InstructorProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> requestToJoin(String instructorId) async {
    try {
      await apiClient.post('/learner/instructors/$instructorId/join');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<InstructorProfileModel>> getMyInstructors() async {
    try {
      final response = await apiClient.get('/learner/my-instructors');
      final dataList = (response.data as List<dynamic>)
          .map((e) => InstructorProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<CourseModel>> getInstructorCourses(String instructorId) async {
    try {
      final response = await apiClient.get(
        '/learner/my-instructors/$instructorId/courses',
      );
      final dataList = (response.data as List<dynamic>)
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<InvitationInfoModel> getInvitationInfo(String token) async {
    try {
      final response = await apiClient.get(
        '/learner/invitations/info',
        queryParameters: {'token': token},
      );
      return InvitationInfoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> acceptInvitation(String token) async {
    try {
      await apiClient.get(
        '/learner/invitations/accept',
        queryParameters: {'token': token},
      );
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
