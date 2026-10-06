import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';

abstract class StorageRemoteDataSource {
  /// GET /instructor/storage/usage
  Future<StorageUsage> getUsage();

  /// GET /instructor/storage/plans
  Future<List<StoragePlan>> getPlans();

  /// POST /instructor/storage/subscribe {planId}
  Future<SubscribeResult> subscribe(String planId);

  /// GET /instructor/revenue
  Future<RevenueSummary> getRevenue();
}

class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  StorageRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<StorageUsage> getUsage() async {
    try {
      final response = await apiClient.get('/instructor/storage/usage');
      return StorageUsage.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<StoragePlan>> getPlans() async {
    try {
      // `/storage/plans` returns a plain JSON array (not an envelope).
      final data = await apiClient.getList('/instructor/storage/plans');
      return data
          .whereType<Map<String, dynamic>>()
          .map(StoragePlan.fromJson)
          .toList();
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SubscribeResult> subscribe(String planId) async {
    try {
      final response = await apiClient.post(
        '/instructor/storage/subscribe',
        data: {'planId': planId},
      );
      return SubscribeResult.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<RevenueSummary> getRevenue() async {
    try {
      final response = await apiClient.get('/instructor/revenue');
      return RevenueSummary.fromJson(response);
    } on ApiException catch (e) {
      throw _handleError(e);
    }
  }

  ServerException _handleError(ApiException e) {
    return ServerException(message: e.message, statusCode: e.statusCode);
  }
}
