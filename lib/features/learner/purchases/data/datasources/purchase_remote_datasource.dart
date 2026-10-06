import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/learner/purchases/domain/entities/purchase_result.dart';

abstract class PurchaseRemoteDataSource {
  /// Purchases a paid course (returns checkoutUrl) or enrolls immediately
  /// for free courses. Returns `already_enrolled` on 409.
  Future<PurchaseResult> purchase(String courseId);
}

class PurchaseRemoteDataSourceImpl implements PurchaseRemoteDataSource {
  PurchaseRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<PurchaseResult> purchase(String courseId) async {
    try {
      final response = await apiClient.post(
        '/learner/courses/$courseId/purchase',
      );
      return PurchaseResult.fromJson(response);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        return const PurchaseResult(status: 'already_enrolled');
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw AuthException(
          message: e.message,
          statusCode: e.statusCode,
          errorCode: e.code,
        );
      }
      throw ServerException(message: e.message, statusCode: e.statusCode);
    }
  }
}
