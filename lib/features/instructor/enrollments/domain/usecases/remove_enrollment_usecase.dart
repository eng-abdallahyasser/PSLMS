import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/enrollments/domain/repositories/enrollment_repository.dart';

class RemoveEnrollmentUseCase {
  final EnrollmentRepository repository;

  RemoveEnrollmentUseCase(this.repository);

  Future<Either<Failure, void>> call(String enrollmentId) {
    return repository.removeEnrollment(enrollmentId);
  }
}
