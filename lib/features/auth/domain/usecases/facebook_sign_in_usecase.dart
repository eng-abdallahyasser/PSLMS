import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class FacebookSignInUseCase {
  final AuthRepository repository;

  FacebookSignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(FacebookSignInParams params) {
    return repository.signInWithFacebook(
      role: params.role,
      client: params.client,
    );
  }
}

class FacebookSignInParams extends Equatable {
  final String role;
  final String client;

  const FacebookSignInParams({
    this.role = 'learner',
    this.client = 'mobile',
  });

  @override
  List<Object> get props => [role, client];
}
