import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructors/domain/repositories/instructor_repository.dart';

class AcceptInvitationUseCase {
  final InstructorRepository repository;

  AcceptInvitationUseCase(this.repository);

  Future<Either<Failure, void>> call(String token) {
    return repository.acceptInvitation(token);
  }
}
