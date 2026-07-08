import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class RequestToJoinUseCase {
  final InstructorRepository repository;

  RequestToJoinUseCase(this.repository);

  Future<Either<Failure, void>> call(String instructorId) {
    return repository.requestToJoin(instructorId);
  }
}
