import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.get('/notifications');
      final dataList = (response.data as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await apiClient.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await apiClient.post('/notifications/read-all');
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
