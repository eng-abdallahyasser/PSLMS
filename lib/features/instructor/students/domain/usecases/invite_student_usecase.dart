import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class InviteStudentUseCase {
  final StudentRepository repository;

  InviteStudentUseCase(this.repository);

  Future<Either<Failure, void>> call(InviteStudentParams params) {
    return repository.inviteStudent(params.email);
  }
}

class InviteStudentParams extends Equatable {
  final String email;

  const InviteStudentParams({required this.email});

  @override
  List<Object> get props => [email];
}
