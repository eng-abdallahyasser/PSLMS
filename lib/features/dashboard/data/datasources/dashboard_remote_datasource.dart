import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/courses/data/models/course_model.dart';

abstract class DashboardRemoteDataSource {
  /// Fetches all courses (with reasonable limit) for computing dashboard stats.
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 50,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CourseModel>> getCourses({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get(
        '/learner/courses',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final dataList = (body['data'] as List<dynamic>)
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
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
