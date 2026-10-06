import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/shared/discovery/domain/entities/category_entity.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';

abstract class DiscoveryRepository {
  /// GET /public/courses — no auth required.
  Future<Either<Failure, List<CourseEntity>>> getPublicCourses({
    int page = 1,
    int limit = 10,
    String? search,
  });

  /// GET /public/courses/{id} — no auth required.
  Future<Either<Failure, CourseEntity>> getPublicCourse(String id);

  /// GET /public/instructors — no auth required.
  Future<Either<Failure, List<InstructorProfileEntity>>> getPublicInstructors({
    int page = 1,
    int limit = 10,
    String? search,
  });

  /// GET /public/instructors/{id} — no auth required.
  Future<Either<Failure, InstructorProfileEntity>> getPublicInstructor(
    String id,
  );

  /// GET /public/categories — no auth required.
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
}
