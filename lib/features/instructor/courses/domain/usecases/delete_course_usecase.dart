import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/courses/domain/repositories/course_repository.dart';

class DeleteCourseUseCase {
  final CourseRepository repository;

  DeleteCourseUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteCourse(id);
  }
}
