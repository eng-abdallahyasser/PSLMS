import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/courses/data/models/course_model.dart';

abstract class DashboardRemoteDataSource {
  /// Fetches courses for computing dashboard stats.
  /// Uses the role to select the correct endpoint.
  Future<List<CourseModel>> getCourses({
    required UserRole role,
    int page = 1,
    int limit = 50,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CourseModel>> getCourses({
    required UserRole role,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final endpoint = role == UserRole.instructor
          ? '/instructor/courses'
          : '/learner/courses';
      final response = await apiClient.get(
        endpoint,
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
