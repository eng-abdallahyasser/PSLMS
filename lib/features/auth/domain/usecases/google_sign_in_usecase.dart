import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository repository;

  GoogleSignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(GoogleSignInParams params) {
    return repository.signInWithGoogle(
      role: params.role,
      client: params.client,
    );
  }
}

class GoogleSignInParams extends Equatable {
  final String role;
  final String client;

  const GoogleSignInParams({
    this.role = 'learner',
    this.client = 'mobile',
  });

  @override
  List<Object> get props => [role, client];
}
