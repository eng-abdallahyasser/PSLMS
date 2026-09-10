import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class InviteStudentUseCase {

  InviteStudentUseCase(this.repository);
  final StudentRepository repository;

  Future<Either<Failure, void>> call(InviteStudentParams params) {
    return repository.inviteStudent(params.email);
  }
}

class InviteStudentParams extends Equatable {

  const InviteStudentParams({required this.email});
  final String email;

  @override
  List<Object> get props => [email];
}
