import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/courses/data/models/course_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> getCourses({int page = 1, int pageSize = 20});
  Future<CourseModel> getCourseById(String id);
  Future<List<CourseModel>> getEnrolledCourses();
  Future<void> enrollCourse(String courseId);
  Future<List<CourseModel>> searchCourses(String query);
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final ApiClient apiClient;

  CourseRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await apiClient.get(
        '/courses',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final data = response.data as List<dynamic>;
      return data
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<CourseModel> getCourseById(String id) async {
    try {
      final response = await apiClient.get('/courses/$id');
      return CourseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<CourseModel>> getEnrolledCourses() async {
    try {
      final response = await apiClient.get('/courses/enrolled');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> enrollCourse(String courseId) async {
    try {
      await apiClient.post('/courses/$courseId/enroll');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final response = await apiClient.get(
        '/courses/search',
        queryParameters: {'q': query},
      );
      final data = response.data as List<dynamic>;
      return data
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(DioException e) {
    if (e.error is ServerException) return e.error as ServerException;
    return ServerException(
      message: e.message ?? 'An error occurred',
      statusCode: e.response?.statusCode,
    );
  }
}
