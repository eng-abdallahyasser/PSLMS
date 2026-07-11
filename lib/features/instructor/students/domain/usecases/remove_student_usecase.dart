import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class RemoveStudentUseCase {

  RemoveStudentUseCase(this.repository);
  final StudentRepository repository;

  Future<Either<Failure, void>> call(RemoveStudentParams params) {
    return repository.removeStudent(params.studentId);
  }
}

class RemoveStudentParams extends Equatable {

  const RemoveStudentParams({required this.studentId});
  final String studentId;

  @override
  List<Object> get props => [studentId];
}
