import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/learner/instructors/data/models/instructor_profile_model.dart';

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
      final body = await apiClient.get(
        '/learner/instructors',
        queryParameters: {'q': query, 'page': page, 'limit': limit},
      );
      final inner = body['data'];
      final rawList = inner is List
          ? inner
          : (inner is Map ? inner['data'] as List<dynamic>? : null);
      final dataList = (rawList ?? [])
          .map(
            (e) => InstructorProfileModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
      final totalItems =
          body['meta']?['totalItems'] as int? ??
          body['totalItems'] as int? ??
          dataList.length;
      return PaginatedInstructors(data: dataList, totalItems: totalItems);
    } on ApiException catch (e) {
      throw _handleError(e);
    } on TypeError catch (e) {
      throw ServerException(
        message: 'Unexpected response format: ${e.toString()}',
        statusCode: null,
      );
    } on FormatException catch (e) {
      throw ServerException(
        message: 'Invalid response format: ${e.toString()}',
        statusCode: null,
      );
    }
  }

  @override
  Future<InstructorProfileModel> getInstructorProfile(String id) async {
    try {
      final response = await apiClient.get('/learner/instructors/$id');
      return InstructorProfileModel.fromJson(response);
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
