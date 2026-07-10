import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/profile/domain/repositories/profile_repository.dart';

class UploadAvatarUseCase {

  UploadAvatarUseCase(this.repository);
  final ProfileRepository repository;

  Future<Either<Failure, String>> call(String filePath) {
    return repository.uploadAvatar(filePath);
  }
}
