import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class RefreshSubscriptionUseCase {
  final SubscriptionRepository repository;

  RefreshSubscriptionUseCase(this.repository);

  Future<Either<Failure, SubscriptionEntity>> call() {
    return repository.refreshSubscription();
  }
}
