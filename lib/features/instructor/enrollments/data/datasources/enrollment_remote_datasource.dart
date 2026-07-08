import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/instructor/courses/data/datasources/course_remote_datasource.dart';
import 'package:lms/features/shared/data/models/course_model.dart';
import 'package:lms/features/shared/data/models/enrollment_model.dart';
import 'package:lms/features/shared/data/models/my_course_detail_model.dart';

abstract class EnrollmentRemoteDataSource {
  /// Learner enrolls in a course. Returns the created enrollment.
  Future<EnrollmentModel> enroll(String courseId);

  /// Learner gets all enrolled courses.
  Future<CoursesResponse> getMyCourses({int page = 1, int limit = 10});

  /// Learner gets detail of an enrolled course with contents.
  Future<MyCourseDetailModel> getMyCourseDetail(String courseId);

  /// Instructor gets all enrollments for a course.
  Future<List<EnrollmentModel>> getEnrollments(String courseId);

  /// Instructor responds to a pending enrollment request.
  Future<void> respondToEnrollment(String enrollmentId, String status);

  /// Instructor invites a learner by email.
  Future<void> inviteLearner(String courseId, String email);

  /// Instructor removes a student from a course.
  Future<void> removeEnrollment(String enrollmentId);
}

class EnrollmentRemoteDataSourceImpl implements EnrollmentRemoteDataSource {
  final ApiClient apiClient;

  EnrollmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<EnrollmentModel> enroll(String courseId) async {
    try {
      final response = await apiClient.post(
        '/learner/courses/$courseId/enroll',
      );
      return EnrollmentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<CoursesResponse> getMyCourses({int page = 1, int limit = 10}) async {
    try {
      final response = await apiClient.get(
        '/learner/my-courses',
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = response.data as Map<String, dynamic>;
      final dataList = (body['data'] as List<dynamic>)
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta = PaginationMeta.fromJson(body['meta'] as Map<String, dynamic>);
      return CoursesResponse(data: dataList, meta: meta);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<MyCourseDetailModel> getMyCourseDetail(String courseId) async {
    try {
      final response = await apiClient.get('/learner/my-courses/$courseId');
      return MyCourseDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<EnrollmentModel>> getEnrollments(String courseId) async {
    try {
      final response = await apiClient.get(
        '/instructor/courses/$courseId/enrollments',
      );
      final data = response.data as List<dynamic>;
      return data
          .map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> respondToEnrollment(String enrollmentId, String status) async {
    try {
      await apiClient.patch(
        '/instructor/enrollments/$enrollmentId/respond',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> inviteLearner(String courseId, String email) async {
    try {
      await apiClient.post(
        '/instructor/courses/$courseId/invite',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> removeEnrollment(String enrollmentId) async {
    try {
      await apiClient.delete('/instructor/enrollments/$enrollmentId');
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
