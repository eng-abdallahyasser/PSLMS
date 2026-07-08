import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/instructor/content/domain/repositories/content_repository.dart';

class GetMyContentDetailUseCase {
  final ContentRepository repository;

  GetMyContentDetailUseCase(this.repository);

  Future<Either<Failure, ContentEntity>> call(
    String courseId,
    String contentId,
  ) {
    return repository.getMyContentDetail(courseId, contentId);
  }
}
