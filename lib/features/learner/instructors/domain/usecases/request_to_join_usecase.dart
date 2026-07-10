import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class RequestToJoinUseCase {

  RequestToJoinUseCase(this.repository);
  final InstructorRepository repository;

  Future<Either<Failure, void>> call(String instructorId) {
    return repository.requestToJoin(instructorId);
  }
}
