import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/learner/instructors/data/datasources/instructor_remote_datasource.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class InstructorRepositoryImpl implements InstructorRepository {
  InstructorRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final InstructorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<InstructorProfileEntity>>> searchInstructors({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
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
      return const Left(NetworkFailure());
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
}
