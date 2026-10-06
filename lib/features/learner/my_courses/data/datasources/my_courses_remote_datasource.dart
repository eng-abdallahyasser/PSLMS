import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/instructor/courses/data/datasources/course_remote_datasource.dart';
import 'package:lms/features/shared/data/models/course_model.dart';
import 'package:lms/features/shared/data/models/my_course_detail_model.dart';

abstract class MyCoursesRemoteDataSource {
  /// GET /learner/my-courses
  Future<CoursesResponse> getMyCourses({int page = 1, int limit = 10});

  /// GET /learner/my-courses/{courseId}
  Future<MyCourseDetailModel> getMyCourseDetail(String courseId);
}

class MyCoursesRemoteDataSourceImpl implements MyCoursesRemoteDataSource {
  MyCoursesRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<CoursesResponse> getMyCourses({int page = 1, int limit = 10}) async {
    try {
      final body = await apiClient.get(
        '/learner/my-courses',
        queryParameters: {'page': page, 'limit': limit},
      );
      // Items are purchase records: `{...purchase, course: {...}}` — the
      // course lives under the `course` key (fallback: plain course object).
      final dataList = (body['data'] as List<dynamic>?)
          ?.map((e) {
            final item = e as Map<String, dynamic>;
            final nested = item['course'];
            return CourseModel.fromJson(
              nested is Map<String, dynamic> ? nested : item,
            );
          })
          .toList() ??
          [];
      final meta = body['meta'] != null
          ? PaginationMeta.fromJson(body['meta'] as Map<String, dynamic>)
          : PaginationMeta.fromJson({
              'totalItems': dataList.length,
              'itemCount': dataList.length,
              'itemsPerPage': limit,
              'totalPages': dataList.length < limit ? 1 : 1,
              'currentPage': page,
            });
      return CoursesResponse(data: dataList, meta: meta);
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
  Future<MyCourseDetailModel> getMyCourseDetail(String courseId) async {
    try {
      final response = await apiClient.get('/learner/my-courses/$courseId');
      return MyCourseDetailModel.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(ApiException e) {
    return ServerException(message: e.message, statusCode: e.statusCode);
  }
}
