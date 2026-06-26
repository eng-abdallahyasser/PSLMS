import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:lms/features/courses/domain/entities/course_entity.dart';
import 'package:lms/features/courses/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CourseRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final courses = await remoteDataSource.getCourses(
        page: page,
        pageSize: pageSize,
      );
      return Right(courses.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> getCourseById(String id) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final course = await remoteDataSource.getCourseById(id);
      return Right(course.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getEnrolledCourses() async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final courses = await remoteDataSource.getEnrolledCourses();
      return Right(courses.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> enrollCourse(String courseId) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.enrollCourse(courseId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> searchCourses(
    String query,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final courses = await remoteDataSource.searchCourses(query);
      return Right(courses.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
