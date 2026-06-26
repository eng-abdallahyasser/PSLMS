import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/contents/domain/entities/content_entity.dart';
import 'package:lms/features/contents/domain/repositories/content_repository.dart';

class GetCourseContentsUseCase {
  final ContentRepository repository;

  GetCourseContentsUseCase(this.repository);

  Future<Either<Failure, List<ContentEntity>>> call(String courseId) {
    return repository.getContents(courseId);
  }
}
