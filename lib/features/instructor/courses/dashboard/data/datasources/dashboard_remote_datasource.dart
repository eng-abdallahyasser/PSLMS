import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/shared/data/models/course_model.dart';

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

  DashboardRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

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
      final body = response;
      final dataList = (body['data'] as List<dynamic>)
          .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
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
