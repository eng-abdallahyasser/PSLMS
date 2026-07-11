import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/instructor/courses/domain/repositories/course_repository.dart';

class GetCoursesUseCase {

  GetCoursesUseCase(this.repository);
  final CourseRepository repository;

  Future<Either<Failure, List<CourseEntity>>> call({
    required UserRole role,
    int page = 1,
    int limit = 10,
    String? search,
    String? visibilityFilter,
  }) {
    return repository.getCourses(
      role: role,
      page: page,
      limit: limit,
      search: search,
      visibilityFilter: visibilityFilter,
    );
  }
}
