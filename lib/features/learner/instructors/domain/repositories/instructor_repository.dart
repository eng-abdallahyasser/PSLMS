import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';

abstract class InstructorRepository {
  Future<Either<Failure, List<InstructorProfileEntity>>> searchInstructors({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, InstructorProfileEntity>> getInstructorProfile(
    String id,
  );
}
