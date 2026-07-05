import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/courses/domain/entities/course_entity.dart';
import 'package:lms/features/enrollments/domain/entities/enrollment_entity.dart';
import 'package:lms/features/enrollments/domain/entities/my_course_detail_entity.dart';

abstract class EnrollmentRepository {
  /// Learner enrolls in a course.
  Future<Either<Failure, EnrollmentEntity>> enroll(String courseId);

  /// Learner gets all enrolled courses.
  Future<Either<Failure, List<CourseEntity>>> getMyCourses({
    int page = 1,
    int limit = 10,
  });

  /// Learner gets detail of an enrolled course with contents.
  Future<Either<Failure, MyCourseDetailEntity>> getMyCourseDetail(
    String courseId,
  );

  /// Instructor gets all enrollments for a course.
  Future<Either<Failure, List<EnrollmentEntity>>> getEnrollments(
    String courseId,
  );

  /// Instructor responds to a pending enrollment request.
  Future<Either<Failure, void>> respondToEnrollment(
    String enrollmentId,
    String status,
  );

  /// Instructor invites a learner by email.
  Future<Either<Failure, void>> inviteLearner(
    String courseId,
    String email,
  );

  /// Instructor removes a student from a course.
  Future<Either<Failure, void>> removeEnrollment(String enrollmentId);
}
