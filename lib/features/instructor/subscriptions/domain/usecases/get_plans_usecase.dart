import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_plan_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class GetPlansUseCase {
  final SubscriptionRepository repository;

  GetPlansUseCase(this.repository);

  Future<Either<Failure, List<SubscriptionPlanEntity>>> call() {
    return repository.getPlans();
  }
}
