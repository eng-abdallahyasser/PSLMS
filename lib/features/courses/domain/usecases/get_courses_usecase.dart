import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/courses/domain/entities/course_entity.dart';
import 'package:lms/features/courses/domain/repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository repository;

  GetCoursesUseCase(this.repository);

  Future<Either<Failure, List<CourseEntity>>> call({
    int page = 1,
    int limit = 10,
    String? search,
    String? visibilityFilter,
  }) {
    return repository.getCourses(
      page: page,
      limit: limit,
      search: search,
      visibilityFilter: visibilityFilter,
    );
  }
}
