import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class GetInstructorCoursesUseCase {
  final InstructorRepository repository;

  GetInstructorCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call(String instructorId) {
    return repository.getInstructorCourses(instructorId);
  }
}
