import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/data/models/device_info_model.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class VerifyMobileOtpUseCase {

  VerifyMobileOtpUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, UserEntity>> call(VerifyMobileOtpParams params) {
    return repository.verifyMobileOtp(
      mobileNumber: params.mobileNumber,
      otp: params.otp,
      client: params.client,
      deviceToken: params.deviceToken,
      deviceInfo: params.deviceInfo,
    );
  }
}

class VerifyMobileOtpParams extends Equatable {

  const VerifyMobileOtpParams({
    required this.mobileNumber,
    required this.otp,
    this.client = 'mobile',
    this.deviceToken,
    this.deviceInfo,
  });
  final String mobileNumber;
  final String otp;
  final String client;
  final String? deviceToken;
  final DeviceInfo? deviceInfo;

  @override
  List<Object?> get props => [mobileNumber, otp, client, deviceToken, deviceInfo];
}
