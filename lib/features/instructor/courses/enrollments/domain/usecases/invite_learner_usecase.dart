import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';

class InviteLearnerUseCase {
  final EnrollmentRepository repository;

  InviteLearnerUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String courseId,
    required String email,
  }) {
    return repository.inviteLearner(courseId, email);
  }
}
