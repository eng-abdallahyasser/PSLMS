import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/data/models/device_info_model.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {

  LoginUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return repository.login(
      email: params.email,
      password: params.password,
      client: params.client,
      deviceToken: params.deviceToken,
      deviceInfo: params.deviceInfo,
    );
  }
}

class LoginParams extends Equatable {

  const LoginParams({
    required this.email,
    required this.password,
    this.client = 'mobile',
    this.deviceToken,
    this.deviceInfo,
  });
  final String email;
  final String password;
  final String client;
  final String? deviceToken;
  final DeviceInfo? deviceInfo;

  @override
  List<Object?> get props => [email, password, client, deviceToken, deviceInfo];
}
