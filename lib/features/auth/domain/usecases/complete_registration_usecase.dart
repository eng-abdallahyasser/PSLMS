import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class CompleteRegistrationUseCase {
  final AuthRepository repository;

  CompleteRegistrationUseCase(this.repository);

  Future<Either<Failure, void>> call(CompleteRegistrationParams params) {
    return repository.completeRegistration(
      tempToken: params.tempToken,
      role: params.role,
      client: params.client,
    );
  }
}

class CompleteRegistrationParams extends Equatable {
  final String tempToken;
  final String? role;
  final String? client;

  const CompleteRegistrationParams({
    required this.tempToken,
    this.role,
    this.client,
  });

  @override
  List<Object?> get props => [tempToken, role, client];
}
