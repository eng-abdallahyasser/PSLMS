import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/learner/instructors/data/datasources/instructor_remote_datasource.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/learner/instructors/domain/entities/invitation_info_entity.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class InstructorRepositoryImpl implements InstructorRepository {
  final InstructorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  InstructorRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<InstructorProfileEntity>>> searchInstructors({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.searchInstructors(
        query: query,
        page: page,
        limit: limit,
      );
      return Right(result.data.map((i) => i.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, InstructorProfileEntity>> getInstructorProfile(
    String id,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final profile = await remoteDataSource.getInstructorProfile(id);
      return Right(profile.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> requestToJoin(String instructorId) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.requestToJoin(instructorId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, List<InstructorProfileEntity>>> getMyInstructors() async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final instructors = await remoteDataSource.getMyInstructors();
      return Right(instructors.map((i) => i.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getInstructorCourses(
    String instructorId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final courses = await remoteDataSource.getInstructorCourses(instructorId);
      return Right(courses.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, InvitationInfoEntity>> getInvitationInfo(
    String token,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final info = await remoteDataSource.getInvitationInfo(token);
      return Right(info.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> acceptInvitation(String token) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.acceptInvitation(token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
