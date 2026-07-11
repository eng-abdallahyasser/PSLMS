import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';

class InviteLearnerUseCase {

  InviteLearnerUseCase(this.repository);
  final EnrollmentRepository repository;

  Future<Either<Failure, void>> call({
    required String courseId,
    required String email,
  }) {
    return repository.inviteLearner(courseId, email);
  }
}
