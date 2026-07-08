import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/instructor/subscriptions/data/datasources/subscription_remote_datasource.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/storage_addon_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_plan_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SubscriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SubscriptionEntity>> getMySubscription() async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final subscription = await remoteDataSource.getMySubscription();
      return Right(subscription.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionPlanEntity>>> getPlans() async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final plans = await remoteDataSource.getPlans();
      return Right(plans.map((p) => p.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, String>> createCheckout({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final url = await remoteDataSource.createCheckout(
        planType: planType,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, String>> createPortal() async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final url = await remoteDataSource.createPortal();
      return Right(url);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, String>> choosePlan({
    required String planType,
    String? successUrl,
    String? cancelUrl,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final url = await remoteDataSource.choosePlan(
        planType: planType,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, String>> buyStorage() async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final url = await remoteDataSource.buyStorage();
      return Right(url);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, List<StorageAddonEntity>>> getStorageAddons() async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final addons = await remoteDataSource.getStorageAddons();
      return Right(addons.map((a) => a.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> refreshSubscription() async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final subscription = await remoteDataSource.refreshSubscription();
      return Right(subscription.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription() async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.cancelSubscription();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
