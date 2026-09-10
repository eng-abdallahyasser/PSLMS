import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/instructor/courses/domain/repositories/course_repository.dart';

class UpdateCourseUseCase {

  UpdateCourseUseCase(this.repository);
  final CourseRepository repository;

  Future<Either<Failure, CourseEntity>> call({
    required String id,
    String? title,
    String? description,
    String? visibility,
    String? thumbnailUrl,
  }) {
    return repository.updateCourse(
      id: id,
      title: title,
      description: description,
      visibility: visibility,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
