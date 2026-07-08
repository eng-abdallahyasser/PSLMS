import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {

  LogoutUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
