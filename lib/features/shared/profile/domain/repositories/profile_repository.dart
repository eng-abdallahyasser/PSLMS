import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();

  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? firstName,
    String? lastName,
  });

  Future<Either<Failure, void>> updatePreferences({
    String? lang,
    String? mode,
  });

  Future<Either<Failure, String>> uploadAvatar(String filePath);
}
