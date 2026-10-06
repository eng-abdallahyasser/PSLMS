import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';

abstract class StorageRepository {
  Future<Either<Failure, StorageUsage>> getUsage();
  Future<Either<Failure, List<StoragePlan>>> getPlans();
  Future<Either<Failure, SubscribeResult>> subscribe(String planId);
  Future<Either<Failure, RevenueSummary>> getRevenue();
}
