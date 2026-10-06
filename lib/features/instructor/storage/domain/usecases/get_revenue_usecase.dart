import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';
import 'package:lms/features/instructor/storage/domain/repositories/storage_repository.dart';

class GetRevenueUseCase {
  GetRevenueUseCase(this.repository);

  final StorageRepository repository;

  Future<Either<Failure, RevenueSummary>> call() {
    return repository.getRevenue();
  }
}
