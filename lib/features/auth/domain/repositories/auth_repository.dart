import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/data/models/device_info_model.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required String client,
    String? deviceToken,
    DeviceInfo? deviceInfo,
  });

  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? client,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String password,
  });

  Future<Either<Failure, bool>> isAuthenticated();

  Future<Either<Failure, String>> refreshToken(String refreshToken);

  Future<Either<Failure, void>> verifyEmail({
    required String email,
    required String otp,
  });

  Future<Either<Failure, void>> sendOtp({
    required String email,
  });

  Future<Either<Failure, void>> completeRegistration({
    required String tempToken,
    String? role,
    String? client,
  });

  Future<Either<Failure, UserEntity>> signInWithGoogle({
    String role = 'learner',
    String client = 'mobile',
  });

  Future<Either<Failure, UserEntity>> signInWithFacebook({
    String role = 'learner',
    String client = 'mobile',
  });
}
