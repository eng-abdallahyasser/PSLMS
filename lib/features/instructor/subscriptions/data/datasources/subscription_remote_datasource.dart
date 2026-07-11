import 'package:dio/dio.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/instructor/subscriptions/data/models/subscription_model.dart';
import 'package:lms/features/instructor/subscriptions/data/models/subscription_plan_model.dart';
import 'package:lms/features/instructor/subscriptions/data/models/storage_addon_model.dart';

abstract class SubscriptionRemoteDataSource {
  /// GET /instructor/subscription
  Future<SubscriptionModel> getMySubscription();

  /// GET /instructor/subscription/plans
  Future<List<SubscriptionPlanModel>> getPlans();

  /// POST /instructor/subscription/checkout
  Future<String> createCheckout({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  });

  /// POST /instructor/subscription/portal
  Future<String> createPortal();

  /// POST /instructor/subscription/choose-plan
  Future<String> choosePlan({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  });

  /// POST /instructor/subscription/storage
  Future<String> buyStorage();

  /// GET /instructor/subscription/storage
  Future<List<StorageAddonModel>> getStorageAddons();

  /// POST /instructor/subscription/refresh-subscription
  Future<SubscriptionModel> refreshSubscription();

  /// POST /instructor/subscription/cancel
  Future<void> cancelSubscription();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {

  SubscriptionRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<SubscriptionModel> getMySubscription() async {
    try {
      final response = await apiClient.get('/instructor/subscription');
      return SubscriptionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<SubscriptionPlanModel>> getPlans() async {
    try {
      final response = await apiClient.get('/instructor/subscription/plans');
      final dataList = (response.data as List<dynamic>)
          .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> createCheckout({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final response = await apiClient.post(
        '/instructor/subscription/checkout',
        data: {
          'planType': planType,
          'successUrl': ?successUrl,
          'cancelUrl': ?cancelUrl,
        },
      );
      final body = response.data as Map<String, dynamic>;
      return body['url'] as String? ?? body['checkoutUrl'] as String? ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> createPortal() async {
    try {
      final response = await apiClient.post('/instructor/subscription/portal');
      final body = response.data as Map<String, dynamic>;
      return body['url'] as String? ?? body['portalUrl'] as String? ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> choosePlan({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final response = await apiClient.post(
        '/instructor/subscription/choose-plan',
        data: {
          'planType': planType,
          'successUrl': ?successUrl,
          'cancelUrl': ?cancelUrl,
        },
      );
      final body = response.data as Map<String, dynamic>;
      return body['url'] as String? ?? body['checkoutUrl'] as String? ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> buyStorage() async {
    try {
      final response = await apiClient.post('/instructor/subscription/storage');
      final body = response.data as Map<String, dynamic>;
      return body['url'] as String? ?? body['checkoutUrl'] as String? ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<StorageAddonModel>> getStorageAddons() async {
    try {
      final response = await apiClient.get('/instructor/subscription/storage');
      final dataList = (response.data as List<dynamic>)
          .map((e) => StorageAddonModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return dataList;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<SubscriptionModel> refreshSubscription() async {
    try {
      final response =
          await apiClient.post('/instructor/subscription/refresh-subscription');
      return SubscriptionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> cancelSubscription() async {
    try {
      await apiClient.post('/instructor/subscription/cancel');
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
