import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:lms/features/profile/domain/entities/profile_entity.dart';
import 'package:lms/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final profile = await remoteDataSource.getProfile();
      return Right(profile.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on AuthException catch (e) {
      return Left(
        AuthFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final profile = await remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
      );
      return Right(profile.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences({
    String? lang,
    String? mode,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.updatePreferences(lang: lang, mode: mode);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final avatarUrl = await remoteDataSource.uploadAvatar(filePath);
      return Right(avatarUrl);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }
}
