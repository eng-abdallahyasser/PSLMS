import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/enrollment_entity.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';

class GetEnrollmentsUseCase {
  final EnrollmentRepository repository;

  GetEnrollmentsUseCase(this.repository);

  Future<Either<Failure, List<EnrollmentEntity>>> call(String courseId) {
    return repository.getEnrollments(courseId);
  }
}
