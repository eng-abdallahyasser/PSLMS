import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_plan_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class GetPlansUseCase {

  GetPlansUseCase(this.repository);
  final SubscriptionRepository repository;

  Future<Either<Failure, List<SubscriptionPlanEntity>>> call() {
    return repository.getPlans();
  }
}
