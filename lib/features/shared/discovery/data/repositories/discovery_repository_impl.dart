import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/shared/discovery/data/datasources/discovery_remote_datasource.dart';
import 'package:lms/features/shared/discovery/domain/entities/category_entity.dart';
import 'package:lms/features/shared/discovery/domain/repositories/discovery_repository.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final DiscoveryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      return Right(await run());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<CourseEntity>>> getPublicCourses({
    int page = 1,
    int limit = 10,
    String? search,
  }) =>
      _guard(() async {
        final courses = await remoteDataSource.getPublicCourses(
          page: page,
          limit: limit,
          search: search,
        );
        return courses.map((c) => c.toEntity()).toList();
      });

  @override
  Future<Either<Failure, CourseEntity>> getPublicCourse(String id) =>
      _guard(() async {
        final course = await remoteDataSource.getPublicCourse(id);
        return course.toEntity();
      });

  @override
  Future<Either<Failure, List<InstructorProfileEntity>>> getPublicInstructors({
    int page = 1,
    int limit = 10,
    String? search,
  }) =>
      _guard(() async {
        final instructors = await remoteDataSource.getPublicInstructors(
          page: page,
          limit: limit,
          search: search,
        );
        return instructors.map((i) => i.toEntity()).toList();
      });

  @override
  Future<Either<Failure, InstructorProfileEntity>> getPublicInstructor(
    String id,
  ) =>
      _guard(() async {
        final instructor = await remoteDataSource.getPublicInstructor(id);
        return instructor.toEntity();
      });

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() =>
      _guard(() async {
        final categories = await remoteDataSource.getCategories();
        return categories.map((c) => c.toEntity()).toList();
      });
}
