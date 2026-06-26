import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/contents/data/datasources/content_remote_datasource.dart';
import 'package:lms/features/contents/domain/entities/content_entity.dart';
import 'package:lms/features/contents/domain/repositories/content_repository.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ContentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ContentEntity>>> getContents(
    String courseId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
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
      return Left(NetworkFailure());
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
}
