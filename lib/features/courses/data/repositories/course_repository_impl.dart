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
    int limit = 10,
    String? search,
    String? visibilityFilter,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.getCourses(
        page: page,
        limit: limit,
        search: search,
        visibilityFilter: visibilityFilter,
      );
      return Right(response.data.map((c) => c.toEntity()).toList());
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
  Future<Either<Failure, CourseEntity>> createCourse({
    required String title,
    required String description,
    String visibility = 'PUBLIC',
    String? thumbnailUrl,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final course = await remoteDataSource.createCourse(
        title: title,
        description: description,
        visibility: visibility,
        thumbnailUrl: thumbnailUrl,
      );
      return Right(course.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, CourseEntity>> updateCourse({
    required String id,
    String? title,
    String? description,
    String? visibility,
    String? thumbnailUrl,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final course = await remoteDataSource.updateCourse(
        id: id,
        title: title,
        description: description,
        visibility: visibility,
        thumbnailUrl: thumbnailUrl,
      );
      return Right(course.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse(String id) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.deleteCourse(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
