import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class CancelSubscriptionUseCase {

  CancelSubscriptionUseCase(this.repository);
  final SubscriptionRepository repository;

  Future<Either<Failure, void>> call() {
    return repository.cancelSubscription();
  }
}
