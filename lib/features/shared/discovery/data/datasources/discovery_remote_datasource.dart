import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/learner/instructors/data/models/instructor_profile_model.dart';
import 'package:lms/features/shared/data/models/course_model.dart';
import 'package:lms/features/shared/discovery/data/models/category_model.dart';

abstract class DiscoveryRemoteDataSource {
  /// GET /public/courses
  Future<List<CourseModel>> getPublicCourses({
    int page = 1,
    int limit = 10,
    String? search,
  });

  /// GET /public/courses/{id}
  Future<CourseModel> getPublicCourse(String id);

  /// GET /public/instructors
  Future<List<InstructorProfileModel>> getPublicInstructors({
    int page = 1,
    int limit = 10,
    String? search,
  });

  /// GET /public/instructors/{id}
  Future<InstructorProfileModel> getPublicInstructor(String id);

  /// GET /public/categories
  Future<List<CategoryModel>> getCategories();
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  DiscoveryRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  Map<String, dynamic> _query({
    required int page,
    required int limit,
    String? search,
  }) {
    final query = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    return query;
  }

  @override
  Future<List<CourseModel>> getPublicCourses({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final result = await apiClient.getPaged(
        '/public/courses',
        queryParameters: _query(page: page, limit: limit, search: search),
      );
      return result.items.map(CourseModel.fromJson).toList();
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<CourseModel> getPublicCourse(String id) async {
    try {
      final response = await apiClient.get('/public/courses/$id');
      return CourseModel.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<InstructorProfileModel>> getPublicInstructors({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final result = await apiClient.getPaged(
        '/public/instructors',
        queryParameters: _query(page: page, limit: limit, search: search),
      );
      return result.items.map(InstructorProfileModel.fromJson).toList();
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<InstructorProfileModel> getPublicInstructor(String id) async {
    try {
      final response = await apiClient.get('/public/instructors/$id');
      return InstructorProfileModel.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final result = await apiClient.getPaged('/public/categories');
      return result.items.map(CategoryModel.fromJson).toList();
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(ApiException e) {
    return ServerException(message: e.message, statusCode: e.statusCode);
  }
}
