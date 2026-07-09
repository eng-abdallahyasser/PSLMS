import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class SendMobileOtpUseCase {

  SendMobileOtpUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call(SendMobileOtpParams params) {
    return repository.sendMobileOtp(
      mobileNumber: params.mobileNumber,
      client: params.client,
    );
  }
}

class SendMobileOtpParams extends Equatable {

  const SendMobileOtpParams({
    required this.mobileNumber,
    this.client = 'mobile',
  });
  final String mobileNumber;
  final String client;

  @override
  List<Object> get props => [mobileNumber, client];
}
