import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/shared/domain/entities/my_course_detail_entity.dart';

abstract class MyCoursesRepository {
  /// Learner gets all enrolled courses.
  Future<Either<Failure, List<CourseEntity>>> getMyCourses({
    int page = 1,
    int limit = 10,
  });

  /// Learner gets detail of an enrolled course with contents.
  Future<Either<Failure, MyCourseDetailEntity>> getMyCourseDetail(
    String courseId,
  );
}
