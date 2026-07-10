import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/my_course_detail_entity.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';

class GetMyCourseDetailUseCase {

  GetMyCourseDetailUseCase(this.repository);
  final EnrollmentRepository repository;

  Future<Either<Failure, MyCourseDetailEntity>> call(String courseId) {
    return repository.getMyCourseDetail(courseId);
  }
}
