import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class GetAssignmentsUseCase {

  GetAssignmentsUseCase(this.repository);
  final StudentRepository repository;

  Future<Either<Failure, List<String>>> call(String studentId) {
    return repository.getAssignments(studentId);
  }
}
