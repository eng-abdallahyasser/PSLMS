import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailUseCase {

  VerifyEmailUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call(VerifyEmailParams params) {
    return repository.verifyEmail(
      email: params.email,
      otp: params.otp,
    );
  }
}

class VerifyEmailParams extends Equatable {

  const VerifyEmailParams({
    required this.email,
    required this.otp,
  });
  final String email;
  final String otp;

  @override
  List<Object> get props => [email, otp];
}
