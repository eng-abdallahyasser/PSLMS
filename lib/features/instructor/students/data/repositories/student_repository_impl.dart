import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/instructor/students/data/datasources/student_remote_datasource.dart';
import 'package:lms/features/instructor/students/domain/entities/student_entity.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StudentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> inviteStudent(String email) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.inviteStudent(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, PaginatedStudents>> listStudents({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.listStudents(
        status: status,
        page: page,
        limit: limit,
      );
      return Right(PaginatedStudents(
        data: response.data.map((m) => m.toEntity()).toList(),
        totalItems: response.totalItems,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, PaginatedStudents>> listRequests({
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.listRequests(
        page: page,
        limit: limit,
      );
      return Right(PaginatedStudents(
        data: response.data.map((m) => m.toEntity()).toList(),
        totalItems: response.totalItems,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> respondToRequest(
    String requestId,
    String action,
  ) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.respondToRequest(requestId, action);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> removeStudent(String studentId) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.removeStudent(studentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> assignCourses(
    String studentId,
    List<String> courseIds,
  ) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.assignCourses(studentId, courseIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAssignments(
    String studentId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final courseIds = await remoteDataSource.getAssignments(studentId);
      return Right(courseIds);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
