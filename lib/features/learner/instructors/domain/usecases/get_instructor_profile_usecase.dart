import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class GetInstructorProfileUseCase {

  GetInstructorProfileUseCase(this.repository);
  final InstructorRepository repository;

  Future<Either<Failure, InstructorProfileEntity>> call(String id) {
    return repository.getInstructorProfile(id);
  }
}
