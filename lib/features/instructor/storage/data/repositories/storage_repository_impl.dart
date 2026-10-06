import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/instructor/storage/data/datasources/storage_remote_datasource.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';
import 'package:lms/features/instructor/storage/domain/repositories/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final StorageRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      return Right(await run());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, StorageUsage>> getUsage() =>
      _guard(remoteDataSource.getUsage);

  @override
  Future<Either<Failure, List<StoragePlan>>> getPlans() =>
      _guard(remoteDataSource.getPlans);

  @override
  Future<Either<Failure, SubscribeResult>> subscribe(String planId) =>
      _guard(() => remoteDataSource.subscribe(planId));

  @override
  Future<Either<Failure, RevenueSummary>> getRevenue() =>
      _guard(remoteDataSource.getRevenue);
}
