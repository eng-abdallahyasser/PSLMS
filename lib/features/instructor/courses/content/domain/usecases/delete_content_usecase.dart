import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/courses/content/domain/repositories/content_repository.dart';

class DeleteContentUseCase {

  DeleteContentUseCase(this.repository);
  final ContentRepository repository;

  Future<Either<Failure, void>> call(DeleteContentParams params) {
    return repository.deleteContent(
      courseId: params.courseId,
      contentId: params.contentId,
    );
  }
}

class DeleteContentParams extends Equatable {

  const DeleteContentParams({
    required this.courseId,
    required this.contentId,
  });
  final String courseId;
  final String contentId;

  @override
  List<Object> get props => [courseId, contentId];
}
