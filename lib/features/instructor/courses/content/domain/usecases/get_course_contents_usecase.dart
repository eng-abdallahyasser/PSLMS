import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/instructor/courses/content/domain/repositories/content_repository.dart';

class GetCourseContentsUseCase {

  GetCourseContentsUseCase(this.repository);
  final ContentRepository repository;

  Future<Either<Failure, List<ContentEntity>>> call(String courseId) {
    return repository.getContents(courseId);
  }
}
