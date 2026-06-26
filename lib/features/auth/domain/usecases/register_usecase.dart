import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return repository.register(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
      role: params.role,
    );
  }
}

class RegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.role = 'learner',
  });

  @override
  List<Object> get props => [firstName, lastName, email, password, role];
}
