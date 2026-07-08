import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/enrollment_entity.dart';
import 'package:lms/features/instructor/enrollments/domain/repositories/enrollment_repository.dart';

class EnrollInCourseUseCase {
  final EnrollmentRepository repository;

  EnrollInCourseUseCase(this.repository);

  Future<Either<Failure, EnrollmentEntity>> call(String courseId) {
    return repository.enroll(courseId);
  }
}
