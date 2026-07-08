import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';

class PaginatedContents {
  final List<ContentEntity> data;
  final int totalItems;

  const PaginatedContents({required this.data, required this.totalItems});
}

abstract class ContentRepository {
  Future<Either<Failure, List<ContentEntity>>> getContents(String courseId);

  Future<Either<Failure, ContentEntity>> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
  });

  /// Get paginated content for an enrolled course (learner).
  Future<Either<Failure, PaginatedContents>> getMyCourseContents(
    String courseId, {
    int page = 1,
    int limit = 10,
  });

  /// Get a single content item detail for an enrolled course (learner).
  Future<Either<Failure, ContentEntity>> getMyContentDetail(
    String courseId,
    String contentId,
  );

  /// Reorder content items within a course (instructor).
  Future<Either<Failure, void>> reorderContent({
    required String courseId,
    required List<String> contentIds,
  });

  /// Update a content item's metadata (instructor).
  Future<Either<Failure, ContentEntity>> updateContent({
    required String courseId,
    required String contentId,
    String? title,
    String? description,
  });

  /// Delete a content item from a course (instructor).
  Future<Either<Failure, void>> deleteContent({
    required String courseId,
    required String contentId,
  });
}
