import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class AssignCoursesUseCase {
  final StudentRepository repository;

  AssignCoursesUseCase(this.repository);

  Future<Either<Failure, void>> call(AssignCoursesParams params) {
    return repository.assignCourses(params.studentId, params.courseIds);
  }
}

class AssignCoursesParams extends Equatable {
  final String studentId;
  final List<String> courseIds;

  const AssignCoursesParams({
    required this.studentId,
    required this.courseIds,
  });

  @override
  List<Object> get props => [studentId, courseIds];
}
