import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/learner/my_courses/domain/repositories/my_courses_repository.dart';

class GetMyCoursesUseCase {

  GetMyCoursesUseCase(this.repository);
  final MyCoursesRepository repository;

  Future<Either<Failure, List<CourseEntity>>> call({
    int page = 1,
    int limit = 10,
  }) {
    return repository.getMyCourses(page: page, limit: limit);
  }
}
