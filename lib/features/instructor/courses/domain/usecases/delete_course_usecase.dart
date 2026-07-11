import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/courses/domain/repositories/course_repository.dart';

class DeleteCourseUseCase {

  DeleteCourseUseCase(this.repository);
  final CourseRepository repository;

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteCourse(id);
  }
}
