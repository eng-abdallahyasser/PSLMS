import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';

class GetMyCoursesUseCase {

  GetMyCoursesUseCase(this.repository);
  final EnrollmentRepository repository;

  Future<Either<Failure, List<CourseEntity>>> call({
    int page = 1,
    int limit = 10,
  }) {
    return repository.getMyCourses(page: page, limit: limit);
  }
}
