import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class CreatePortalUseCase {

  CreatePortalUseCase(this.repository);
  final SubscriptionRepository repository;

  Future<Either<Failure, String>> call() {
    return repository.createPortal();
  }
}
