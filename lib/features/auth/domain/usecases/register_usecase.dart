import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {

  RegisterUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      mobileNumber: params.mobileNumber,
      password: params.password,
      role: params.role,
      client: params.client,
    );
  }
}

class RegisterParams extends Equatable {

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNumber,
    required this.password,
    this.role = 'learner',
    this.client,
  });
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNumber;
  final String password;
  final String role;
  final String? client;

  @override
  List<Object?> get props => [firstName, lastName, email, mobileNumber, password, role, client];
}
