import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/instructor/courses/content/data/datasources/content_remote_datasource.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';
import 'package:lms/features/instructor/courses/content/domain/repositories/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {

  ContentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final ContentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<ContentEntity>>> getContents(
    String courseId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final contents = await remoteDataSource.getContents(courseId);
      return Right(contents.map((c) => c.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, ContentEntity>> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final content = await remoteDataSource.uploadContent(
        courseId: courseId,
        filePath: filePath,
        title: title,
        description: description,
      );
      return Right(content.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, PaginatedContents>> getMyCourseContents(
    String courseId, {
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await remoteDataSource.getMyCourseContents(
        courseId,
        page: page,
        limit: limit,
      );
      return Right(PaginatedContents(
        data: response.data.map((c) => c.toEntity()).toList(),
        totalItems: response.totalItems,
      ));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> reorderContent({
    required String courseId,
    required List<String> contentIds,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.reorderContent(
        courseId: courseId,
        contentIds: contentIds,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, ContentEntity>> updateContent({
    required String courseId,
    required String contentId,
    String? title,
    String? description,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final content = await remoteDataSource.updateContent(
        courseId: courseId,
        contentId: contentId,
        title: title,
        description: description,
      );
      return Right(content.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteContent({
    required String courseId,
    required String contentId,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.deleteContent(
        courseId: courseId,
        contentId: contentId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, ContentEntity>> getMyContentDetail(
    String courseId,
    String contentId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final content = await remoteDataSource.getMyContentDetail(
        courseId,
        contentId,
      );
      return Right(content.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
