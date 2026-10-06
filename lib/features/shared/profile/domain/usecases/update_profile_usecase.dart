import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/profile/domain/entities/profile_entity.dart';
import 'package:lms/features/shared/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase {

  UpdateProfileUseCase(this.repository);
  final ProfileRepository repository;

  Future<Either<Failure, ProfileEntity>> call({
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? universityId,
    String? faculty,
    String? department,
    String? year,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      universityId: universityId,
      faculty: faculty,
      department: department,
      year: year,
    );
  }
}
