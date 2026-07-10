import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/instructor/courses/content/domain/repositories/content_repository.dart';

class PaginatedContentsResult {

  const PaginatedContentsResult({required this.data, required this.totalItems});
  final List<ContentEntity> data;
  final int totalItems;
}

class GetMyCourseContentsUseCase {

  GetMyCourseContentsUseCase(this.repository);
  final ContentRepository repository;

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
