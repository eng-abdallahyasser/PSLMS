import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {

  ResetPasswordUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      token: params.token,
      password: params.newPassword,
    );
  }
}

class ResetPasswordParams extends Equatable {

  const ResetPasswordParams({
    required this.token,
    required this.newPassword,
  });
  final String token;
  final String newPassword;

  @override
  List<Object> get props => [token, newPassword];
}
