import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/shared/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {

  NotificationRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.getList('/notifications');
      final dataList = (response)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await apiClient.patch('/notifications/$id/read');
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await apiClient.post('/notifications/read-all');
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
