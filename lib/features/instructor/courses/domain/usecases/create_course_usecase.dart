import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/instructor/courses/domain/repositories/course_repository.dart';

class CreateCourseUseCase {
  final CourseRepository repository;

  CreateCourseUseCase(this.repository);

  Future<Either<Failure, CourseEntity>> call({
    required String title,
    required String description,
    String visibility = 'PUBLIC',
    String? thumbnailUrl,
  }) {
    return repository.createCourse(
      title: title,
      description: description,
      visibility: visibility,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
