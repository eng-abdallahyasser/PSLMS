import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/courses/domain/entities/course_entity.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, CourseEntity>> getCourseById(String id);

  Future<Either<Failure, List<CourseEntity>>> getEnrolledCourses();

  Future<Either<Failure, void>> enrollCourse(String courseId);

  Future<Either<Failure, List<CourseEntity>>> searchCourses(String query);
}
