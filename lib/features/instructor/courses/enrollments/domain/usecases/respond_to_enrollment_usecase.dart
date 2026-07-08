import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';

class RespondToEnrollmentUseCase {
  final EnrollmentRepository repository;

  RespondToEnrollmentUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String enrollmentId,
    required String status,
  }) {
    return repository.respondToEnrollment(enrollmentId, status);
  }
}
