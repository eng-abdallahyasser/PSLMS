import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/courses/data/models/course_model.dart';

/// Pagination metadata returned by the API.
class PaginationMeta {
  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const PaginationMeta({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      totalItems: json['totalItems'] as int? ?? json['total_items'] as int? ?? 0,
      itemCount: json['itemCount'] as int? ?? json['item_count'] as int? ?? 0,
      itemsPerPage: json['itemsPerPage'] as int? ?? json['items_per_page'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? json['total_pages'] as int? ?? 1,
      currentPage: json['currentPage'] as int? ?? json['current_page'] as int? ?? 1,
    );
  }
}

abstract class CourseRemoteDataSource {
  Future<CoursesResponse> getCourses({
    int page = 1,
    int limit = 10,
    String? search,
    String? visibilityFilter,
  });

  Future<CourseModel> getCourseById(String id);

  Future<CourseModel> createCourse({
    required String title,
    required String description,
    String visibility = 'PUBLIC',
    String? thumbnailUrl,
  });

  Future<CourseModel> updateCourse({
    required String id,
    String? title,
    String? description,
    String? visibility,
    String? thumbnailUrl,
  });

  Future<void> deleteCourse(String id);
}

class CoursesResponse {
  final List<CourseModel> data;
  final PaginationMeta meta;

  const CoursesResponse({required this.data, required this.meta});
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final ApiClient apiClient;

  CourseRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<CoursesResponse> getCourses({
    int page = 1,
    int limit = 10,
    String? search,
    String? visibilityFilter,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (visibilityFilter != null && visibilityFilter.isNotEmpty) {
        queryParams['filter.visibility'] = '\$eq:$visibilityFilter';
      }

      final response = await apiClient.get(
        '/courses',
        queryParameters: queryParams,
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
  Future<CourseModel> getCourseById(String id) async {
    try {
      final response = await apiClient.get('/courses/$id');
      return CourseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<CourseModel> createCourse({
    required String title,
    required String description,
    String visibility = 'PUBLIC',
    String? thumbnailUrl,
  }) async {
    try {
      final response = await apiClient.post(
        '/courses',
        data: {
          'title': title,
          'description': description,
          'visibility': visibility,
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        },
      );
      return CourseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<CourseModel> updateCourse({
    required String id,
    String? title,
    String? description,
    String? visibility,
    String? thumbnailUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (visibility != null) data['visibility'] = visibility;
      if (thumbnailUrl != null) data['thumbnailUrl'] = thumbnailUrl;

      final response = await apiClient.patch('/courses/$id', data: data);
      return CourseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    try {
      await apiClient.delete('/courses/$id');
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
