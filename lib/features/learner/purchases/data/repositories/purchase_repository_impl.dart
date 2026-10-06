import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/learner/purchases/data/datasources/purchase_remote_datasource.dart';
import 'package:lms/features/learner/purchases/domain/entities/purchase_result.dart';
import 'package:lms/features/learner/purchases/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final PurchaseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, PurchaseResult>> purchaseCourse(
    String courseId,
  ) async {
    if (await networkInfo.isConnected == false) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.purchase(courseId);
      return Right(result);
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
}
