import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/instructor/courses/enrollments/data/datasources/enrollment_remote_datasource.dart';
import 'package:lms/features/shared/domain/entities/enrollment_entity.dart';
import 'package:lms/features/shared/domain/entities/my_course_detail_entity.dart';
import 'package:lms/features/instructor/courses/enrollments/domain/repositories/enrollment_repository.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final EnrollmentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EnrollmentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, EnrollmentEntity>> enroll(String courseId) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final enrollment = await remoteDataSource.enroll(courseId);
      return Right(enrollment.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getMyCourses({
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.getMyCourses(page: page, limit: limit);
      return Right(response.data.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, MyCourseDetailEntity>> getMyCourseDetail(
    String courseId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final detail = await remoteDataSource.getMyCourseDetail(courseId);
      return Right(detail.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, List<EnrollmentEntity>>> getEnrollments(
    String courseId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final enrollments = await remoteDataSource.getEnrollments(courseId);
      return Right(enrollments.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> respondToEnrollment(
    String enrollmentId,
    String status,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.respondToEnrollment(enrollmentId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> inviteLearner(
    String courseId,
    String email,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.inviteLearner(courseId, email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeEnrollment(String enrollmentId) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.removeEnrollment(enrollmentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
