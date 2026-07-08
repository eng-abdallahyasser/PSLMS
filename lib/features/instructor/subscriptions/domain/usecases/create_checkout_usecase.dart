import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class CreateCheckoutUseCase {
  final SubscriptionRepository repository;

  CreateCheckoutUseCase(this.repository);

  Future<Either<Failure, String>> call(CreateCheckoutParams params) {
    return repository.createCheckout(
      planType: params.planType,
      successUrl: params.successUrl,
      cancelUrl: params.cancelUrl,
    );
  }
}

class CreateCheckoutParams extends Equatable {
  final String planType;
  final String? successUrl;
  final String? cancelUrl;

  const CreateCheckoutParams({
    required this.planType,
    this.successUrl,
    this.cancelUrl,
  });

  @override
  List<Object?> get props => [planType, successUrl, cancelUrl];
}
