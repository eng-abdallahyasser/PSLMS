import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/discovery/domain/repositories/discovery_repository.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';

class GetPublicCoursesUseCase {
  GetPublicCoursesUseCase(this.repository);

  final DiscoveryRepository repository;

  Future<Either<Failure, List<CourseEntity>>> call({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return repository.getPublicCourses(page: page, limit: limit, search: search);
  }
}
