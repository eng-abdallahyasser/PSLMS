import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/profile/domain/entities/profile_entity.dart';
import 'package:lms/features/shared/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {

  GetProfileUseCase(this.repository);
  final ProfileRepository repository;

  Future<Either<Failure, ProfileEntity>> call() {
    return repository.getProfile();
  }
}
