import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/storage_addon_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class GetStorageAddonsUseCase {

  GetStorageAddonsUseCase(this.repository);
  final SubscriptionRepository repository;

  Future<Either<Failure, List<StorageAddonEntity>>> call() {
    return repository.getStorageAddons();
  }
}
