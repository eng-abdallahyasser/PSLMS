import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/instructor/courses/data/datasources/course_remote_datasource.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/instructor/courses/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {

  CourseRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final CourseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<CourseEntity>>> getCourses({
    required UserRole role,
    int page = 1,
    int limit = 10,
    String? search,
    String? visibilityFilter,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.getCourses(
        role: role,
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
      return const Left(NetworkFailure());
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
      return const Left(NetworkFailure());
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
      return const Left(NetworkFailure());
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
      return const Left(NetworkFailure());
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
