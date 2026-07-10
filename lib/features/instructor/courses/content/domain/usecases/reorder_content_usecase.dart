import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/courses/content/domain/repositories/content_repository.dart';

class ReorderContentUseCase {

  ReorderContentUseCase(this.repository);
  final ContentRepository repository;

  Future<Either<Failure, void>> call(ReorderContentParams params) {
    return repository.reorderContent(
      courseId: params.courseId,
      contentIds: params.contentIds,
    );
  }
}

class ReorderContentParams extends Equatable {

  const ReorderContentParams({
    required this.courseId,
    required this.contentIds,
  });
  final String courseId;
  final List<String> contentIds;

  @override
  List<Object> get props => [courseId, contentIds];
}
