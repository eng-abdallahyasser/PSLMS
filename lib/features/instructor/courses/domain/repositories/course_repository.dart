import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';

abstract class CourseRepository {
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    required UserRole role,
    int page = 1,
    int limit = 10,
    String? search,
    String? visibilityFilter,
  });

  Future<Either<Failure, CourseEntity>> getCourseById(String id);

  Future<Either<Failure, CourseEntity>> createCourse({
    required String title,
    required String description,
    String visibility = 'PUBLIC',
    String? thumbnailUrl,
  });

  Future<Either<Failure, CourseEntity>> updateCourse({
    required String id,
    String? title,
    String? description,
    String? visibility,
    String? thumbnailUrl,
  });

  Future<Either<Failure, void>> deleteCourse(String id);
}
