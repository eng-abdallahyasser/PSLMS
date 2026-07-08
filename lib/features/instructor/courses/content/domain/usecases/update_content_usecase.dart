import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/instructor/courses/content/domain/repositories/content_repository.dart';

class UpdateContentUseCase {
  final ContentRepository repository;

  UpdateContentUseCase(this.repository);

  Future<Either<Failure, ContentEntity>> call(UpdateContentParams params) {
    return repository.updateContent(
      courseId: params.courseId,
      contentId: params.contentId,
      title: params.title,
      description: params.description,
    );
  }
}

class UpdateContentParams extends Equatable {
  final String courseId;
  final String contentId;
  final String? title;
  final String? description;

  const UpdateContentParams({
    required this.courseId,
    required this.contentId,
    this.title,
    this.description,
  });

  @override
  List<Object?> get props => [courseId, contentId, title, description];
}
