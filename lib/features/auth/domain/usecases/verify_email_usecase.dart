import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<Either<Failure, void>> call(VerifyEmailParams params) {
    return repository.verifyEmail(
      email: params.email,
      otp: params.otp,
    );
  }
}

class VerifyEmailParams extends Equatable {
  final String email;
  final String otp;

  const VerifyEmailParams({
    required this.email,
    required this.otp,
  });

  @override
  List<Object> get props => [email, otp];
}
