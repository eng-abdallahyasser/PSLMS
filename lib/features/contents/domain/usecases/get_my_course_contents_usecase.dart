import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/contents/domain/entities/content_entity.dart';
import 'package:lms/features/contents/domain/repositories/content_repository.dart';

class PaginatedContentsResult {
  final List<ContentEntity> data;
  final int totalItems;

  const PaginatedContentsResult({required this.data, required this.totalItems});
}

class GetMyCourseContentsUseCase {
  final ContentRepository repository;

  GetMyCourseContentsUseCase(this.repository);

  Future<Either<Failure, PaginatedContentsResult>> call(
    String courseId, {
    int page = 1,
    int limit = 10,
  }) async {
    final result = await repository.getMyCourseContents(
      courseId,
      page: page,
      limit: limit,
    );
    return result.fold(
      Left.new,
      (paginated) => Right(PaginatedContentsResult(
        data: paginated.data,
        totalItems: paginated.totalItems,
      )),
    );
  }
}
