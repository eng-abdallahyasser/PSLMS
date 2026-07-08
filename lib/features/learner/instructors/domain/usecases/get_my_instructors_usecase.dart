import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class GetMyInstructorsUseCase {
  final InstructorRepository repository;

  GetMyInstructorsUseCase(this.repository);

  Future<Either<Failure, List<InstructorProfileEntity>>> call() {
    return repository.getMyInstructors();
  }
}
