import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class SendOtpUseCase {

  SendOtpUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call(SendOtpParams params) {
    return repository.sendOtp(email: params.email);
  }
}

class SendOtpParams extends Equatable {

  const SendOtpParams({required this.email});
  final String email;

  @override
  List<Object> get props => [email];
}
