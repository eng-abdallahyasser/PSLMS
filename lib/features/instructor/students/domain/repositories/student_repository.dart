import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/entities/student_entity.dart';

class PaginatedStudents {
  final List<StudentEntity> data;
  final int totalItems;

  const PaginatedStudents({required this.data, required this.totalItems});
}

abstract class StudentRepository {
  Future<Either<Failure, void>> inviteStudent(String email);
  Future<Either<Failure, PaginatedStudents>> listStudents({
    String? status,
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, PaginatedStudents>> listRequests({
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, void>> respondToRequest(String requestId, String action);
  Future<Either<Failure, void>> removeStudent(String studentId);
  Future<Either<Failure, void>> assignCourses(
      String studentId, List<String> courseIds);
  Future<Either<Failure, List<String>>> getAssignments(String studentId);
}
