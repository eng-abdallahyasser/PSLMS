import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class AssignCoursesUseCase {

  AssignCoursesUseCase(this.repository);
  final StudentRepository repository;

  Future<Either<Failure, void>> call(AssignCoursesParams params) {
    return repository.assignCourses(params.studentId, params.courseIds);
  }
}

class AssignCoursesParams extends Equatable {

  const AssignCoursesParams({
    required this.studentId,
    required this.courseIds,
  });
  final String studentId;
  final List<String> courseIds;

  @override
  List<Object> get props => [studentId, courseIds];
}
