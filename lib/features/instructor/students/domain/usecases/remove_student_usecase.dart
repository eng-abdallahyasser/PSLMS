import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class RemoveStudentUseCase {
  final StudentRepository repository;

  RemoveStudentUseCase(this.repository);

  Future<Either<Failure, void>> call(RemoveStudentParams params) {
    return repository.removeStudent(params.studentId);
  }
}

class RemoveStudentParams extends Equatable {
  final String studentId;

  const RemoveStudentParams({required this.studentId});

  @override
  List<Object> get props => [studentId];
}
