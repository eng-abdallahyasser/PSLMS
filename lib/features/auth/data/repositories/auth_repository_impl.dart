import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:lms/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lms/features/auth/data/models/device_info_model.dart';
import 'package:lms/features/auth/data/models/user_model.dart';
import 'package:lms/features/auth/data/services/social_auth_service.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.socialAuthService,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SocialAuthService socialAuthService;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
    required String client,
    String? deviceToken,
    DeviceInfo? deviceInfo,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final loginResponse = await remoteDataSource.login(
        email: email,
        password: password,
        client: client,
        deviceToken: deviceToken,
        deviceInfo: deviceInfo,
      );
      await localDataSource.saveToken(loginResponse.accessToken);
      await localDataSource.saveRefreshToken(loginResponse.refreshToken);
      await localDataSource.cacheUser(loginResponse.user);
      return Right(loginResponse.user.toEntity());
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
  Future<Either<Failure, UserEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    String? client,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final userModel = await remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
        client: client,
      );
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    return _handleCachedOrRemote(
      remoteCall: () async {
        if (await networkInfo.isConnected == false) {
          throw const NetworkException();
        }
        return remoteDataSource.getCurrentUser();
      },
      cacheCall: () => localDataSource.getCachedUser(),
      cacheWriteCall: (user) => localDataSource.cacheUser(user),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Proceed with local logout even if remote fails
    }
    try {
      await localDataSource.clearCache();
      await localDataSource.clearToken();
      await localDataSource.clearRefreshToken();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String password,
  }) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      await remoteDataSource.resetPassword(
        token: token,
        password: password,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localDataSource.getToken();
      return Right(token != null && token.isNotEmpty);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    if (await networkInfo.isConnected == false) {
      return Left(NetworkFailure());
    }
    try {
      final newAccessToken = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveToken(newAccessToken);
      return Right(newAccessToken);
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
  Future<Either<Failure, void>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.verifyEmail(email: email, otp: otp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendOtp({
    required String email,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.sendOtp(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, void>> completeRegistration({
    required String tempToken,
    String? role,
    String? client,
  }) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      await remoteDataSource.completeRegistration(
        tempToken: tempToken,
        role: role,
        client: client,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle({
    String role = 'learner',
    String client = 'mobile',
  }) async {
    try {
      final result = await socialAuthService.signInWithGoogle(
        role: role,
        client: client,
      );

      if (result.needsRegistration) {
        return Left(ServerFailure(
          message: 'Registration incomplete',
          statusCode: 400,
        ));
      }

      if (result.accessToken != null) {
        await localDataSource.saveToken(result.accessToken!);
      }
      if (result.refreshToken != null) {
        await localDataSource.saveRefreshToken(result.refreshToken!);
      }

      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on SocialAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook({
    String role = 'learner',
    String client = 'mobile',
  }) async {
    try {
      final result = await socialAuthService.signInWithFacebook(
        role: role,
        client: client,
      );

      if (result.needsRegistration) {
        return Left(ServerFailure(
          message: 'Registration incomplete',
          statusCode: 400,
        ));
      }

      if (result.accessToken != null) {
        await localDataSource.saveToken(result.accessToken!);
      }
      if (result.refreshToken != null) {
        await localDataSource.saveRefreshToken(result.refreshToken!);
      }

      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(user);
      return Right(user.toEntity());
    } on SocialAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  /// Helper to try remote first, fall back to cache.
  Future<Either<Failure, UserEntity>> _handleCachedOrRemote({
    required Future<UserModel> Function() remoteCall,
    required Future<UserModel?> Function() cacheCall,
    required Future<void> Function(UserModel) cacheWriteCall,
  }) async {
    try {
      final userModel = await remoteCall();
      await cacheWriteCall(userModel);
      return Right(userModel.toEntity());
    } on NetworkException {
      // Offline — try cache
      try {
        final cached = await cacheCall();
        if (cached != null) {
          return Right(cached.toEntity());
        }
        return Left(NetworkFailure());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
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
}
