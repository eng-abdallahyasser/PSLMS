import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/enrollments/domain/entities/my_course_detail_entity.dart';
import 'package:lms/features/enrollments/domain/repositories/enrollment_repository.dart';

class GetMyCourseDetailUseCase {
  final EnrollmentRepository repository;

  GetMyCourseDetailUseCase(this.repository);

  Future<Either<Failure, MyCourseDetailEntity>> call(String courseId) {
    return repository.getMyCourseDetail(courseId);
  }
}
