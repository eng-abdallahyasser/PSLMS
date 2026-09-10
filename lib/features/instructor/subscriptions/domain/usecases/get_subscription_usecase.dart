import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class GetSubscriptionUseCase {

  GetSubscriptionUseCase(this.repository);
  final SubscriptionRepository repository;

  Future<Either<Failure, SubscriptionEntity>> call() {
    return repository.getMySubscription();
  }
}
