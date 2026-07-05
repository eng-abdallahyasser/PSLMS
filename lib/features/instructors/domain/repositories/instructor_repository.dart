import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/courses/domain/entities/course_entity.dart';
import 'package:lms/features/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/instructors/domain/entities/invitation_info_entity.dart';

abstract class InstructorRepository {
  Future<Either<Failure, List<InstructorProfileEntity>>> searchInstructors({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, InstructorProfileEntity>> getInstructorProfile(
    String id,
  );

  Future<Either<Failure, void>> requestToJoin(String instructorId);

  Future<Either<Failure, List<InstructorProfileEntity>>> getMyInstructors();

  Future<Either<Failure, List<CourseEntity>>> getInstructorCourses(
    String instructorId,
  );

  Future<Either<Failure, InvitationInfoEntity>> getInvitationInfo(
    String token,
  );

  Future<Either<Failure, void>> acceptInvitation(String token);
}
