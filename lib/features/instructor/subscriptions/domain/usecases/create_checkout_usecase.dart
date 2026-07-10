import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/subscriptions/domain/repositories/subscription_repository.dart';

class CreateCheckoutUseCase {

  CreateCheckoutUseCase(this.repository);
  final SubscriptionRepository repository;

  Future<Either<Failure, String>> call(CreateCheckoutParams params) {
    return repository.createCheckout(
      planType: params.planType,
      successUrl: params.successUrl,
      cancelUrl: params.cancelUrl,
    );
  }
}

class CreateCheckoutParams extends Equatable {

  const CreateCheckoutParams({
    required this.planType,
    this.successUrl,
    this.cancelUrl,
  });
  final String planType;
  final String? successUrl;
  final String? cancelUrl;

  @override
  List<Object?> get props => [planType, successUrl, cancelUrl];
}
