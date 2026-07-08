import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_plan_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/storage_addon_entity.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, SubscriptionEntity>> getMySubscription();

  Future<Either<Failure, List<SubscriptionPlanEntity>>> getPlans();

  Future<Either<Failure, String>> createCheckout({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  });

  Future<Either<Failure, String>> createPortal();

  Future<Either<Failure, String>> choosePlan({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  });

  Future<Either<Failure, String>> buyStorage();

  Future<Either<Failure, List<StorageAddonEntity>>> getStorageAddons();

  Future<Either<Failure, SubscriptionEntity>> refreshSubscription();

  Future<Either<Failure, void>> cancelSubscription();
}
