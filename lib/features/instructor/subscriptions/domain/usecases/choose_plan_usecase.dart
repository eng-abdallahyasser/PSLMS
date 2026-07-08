import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class ChoosePlanUseCase {
  final SubscriptionRepository repository;

  ChoosePlanUseCase(this.repository);

  Future<Either<Failure, String>> call(ChoosePlanParams params) {
    return repository.choosePlan(
      planType: params.planType,
      successUrl: params.successUrl,
      cancelUrl: params.cancelUrl,
    );
  }
}

class ChoosePlanParams extends Equatable {
  final String planType;
  final String? successUrl;
  final String? cancelUrl;

  const ChoosePlanParams({
    required this.planType,
    this.successUrl,
    this.cancelUrl,
  });

  @override
  List<Object?> get props => [planType, successUrl, cancelUrl];
}
