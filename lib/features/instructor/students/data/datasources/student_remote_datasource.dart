import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/instructor/students/data/models/student_model.dart';

class StudentsResponse {

  const StudentsResponse({required this.data, required this.totalItems});
  final List<StudentModel> data;
  final int totalItems;
}

abstract class StudentRemoteDataSource {
  Future<void> inviteStudent(String email);
  Future<StudentsResponse> listStudents({
    String? status,
    int page = 1,
    int limit = 10,
  });
  Future<StudentsResponse> listRequests({int page = 1, int limit = 10});
  Future<void> respondToRequest(String requestId, String action);
  Future<void> removeStudent(String studentId);
  Future<void> assignCourses(String studentId, List<String> courseIds);
  Future<List<String>> getAssignments(String studentId);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {

  StudentRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<void> inviteStudent(String email) async {
    try {
      await apiClient.post(
        '/instructor/students/invite',
        data: {'email': email},
      );
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<StudentsResponse> listStudents({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;

      final response = await apiClient.get(
        '/instructor/students',
        queryParameters: queryParams,
      );
      final body = response;
      final items = (body['items'] ?? body['data']) as List<dynamic>? ?? [];
      final dataList = items
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final totalItems = body['meta']?['total'] as int? ??
          body['meta']?['totalItems'] as int? ??
          body['totalItems'] as int? ??
          dataList.length;
      return StudentsResponse(data: dataList, totalItems: totalItems);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<StudentsResponse> listRequests({int page = 1, int limit = 10}) async {
    try {
      final response = await apiClient.get(
        '/instructor/students/requests',
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = response;
      final items = (body['items'] ?? body['data']) as List<dynamic>? ?? [];
      final dataList = items
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final totalItems = body['meta']?['total'] as int? ??
          body['meta']?['totalItems'] as int? ??
          body['totalItems'] as int? ??
          dataList.length;
      return StudentsResponse(data: dataList, totalItems: totalItems);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> respondToRequest(String requestId, String action) async {
    try {
      await apiClient.patch(
        '/instructor/students/requests/$requestId/respond',
        data: {'action': action},
      );
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> removeStudent(String studentId) async {
    try {
      await apiClient.delete('/instructor/students/$studentId');
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> assignCourses(String studentId, List<String> courseIds) async {
    try {
      await apiClient.post(
        '/instructor/students/$studentId/assign',
        data: {'courseIds': courseIds},
      );
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<String>> getAssignments(String studentId) async {
    try {
      final response =
          await apiClient.get('/instructor/students/$studentId/assignments');
      final body = response;
      final dataList = (body['data'] as List<dynamic>? ?? body['courseIds'] as List<dynamic>? ?? [])
          .map((e) => e as String)
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
