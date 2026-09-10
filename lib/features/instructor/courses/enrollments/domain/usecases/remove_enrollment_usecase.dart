import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';

class RemoveEnrollmentUseCase {

  RemoveEnrollmentUseCase(this.repository);
  final EnrollmentRepository repository;

  Future<Either<Failure, void>> call(String enrollmentId) {
    return repository.removeEnrollment(enrollmentId);
  }
}
