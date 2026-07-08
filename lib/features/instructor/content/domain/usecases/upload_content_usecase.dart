import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/instructor/content/domain/repositories/content_repository.dart';

class UploadContentUseCase {
  final ContentRepository repository;

  UploadContentUseCase(this.repository);

  Future<Either<Failure, ContentEntity>> call({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
  }) {
    return repository.uploadContent(
      courseId: courseId,
      filePath: filePath,
      title: title,
      description: description,
    );
  }
}
