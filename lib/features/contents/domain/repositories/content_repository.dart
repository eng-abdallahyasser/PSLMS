import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/contents/domain/entities/content_entity.dart';

abstract class ContentRepository {
  Future<Either<Failure, List<ContentEntity>>> getContents(String courseId);

  Future<Either<Failure, ContentEntity>> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
  });
}
