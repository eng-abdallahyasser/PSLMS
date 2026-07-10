import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {

  ForgotPasswordUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call(ForgotPasswordParams params) {
    return repository.forgotPassword(params.email);
  }
}

class ForgotPasswordParams extends Equatable {

  const ForgotPasswordParams({required this.email});
  final String email;

  @override
  List<Object> get props => [email];
}
