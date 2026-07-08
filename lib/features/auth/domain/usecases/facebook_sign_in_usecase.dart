import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class FacebookSignInUseCase {

  FacebookSignInUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, UserEntity>> call(FacebookSignInParams params) {
    return repository.signInWithFacebook(
      role: params.role,
      client: params.client,
    );
  }
}

class FacebookSignInParams extends Equatable {

  const FacebookSignInParams({
    this.role = 'learner',
    this.client = 'mobile',
  });
  final String role;
  final String client;

  @override
  List<Object> get props => [role, client];
}
