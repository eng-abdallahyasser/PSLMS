import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/learner/my_courses/data/datasources/my_courses_remote_datasource.dart';
import 'package:lms/features/learner/my_courses/domain/repositories/my_courses_repository.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/shared/domain/entities/my_course_detail_entity.dart';

class MyCoursesRepositoryImpl implements MyCoursesRepository {
  MyCoursesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final MyCoursesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<CourseEntity>>> getMyCourses({
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.getMyCourses(
        page: page,
        limit: limit,
      );
      return Right(response.data.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyCourseDetailEntity>> getMyCourseDetail(
    String courseId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final detail = await remoteDataSource.getMyCourseDetail(courseId);
      return Right(detail.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
