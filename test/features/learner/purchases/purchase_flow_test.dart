import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/learner/purchases/data/datasources/purchase_remote_datasource.dart';
import 'package:lms/features/learner/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:lms/features/learner/purchases/domain/entities/purchase_result.dart';
import 'package:lms/features/learner/purchases/domain/usecases/purchase_course_usecase.dart';
import 'package:lms/features/learner/purchases/presentation/cubit/purchase_cubit.dart';

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo({this.connected = true});
  final bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<InternetConnectionStatus> get onStatusChange => const Stream.empty();
}

class _FakePurchaseRemoteDataSource implements PurchaseRemoteDataSource {
  _FakePurchaseRemoteDataSource({this.result, this.error});
  PurchaseResult? result;
  Object? error;

  @override
  Future<PurchaseResult> purchase(String courseId) async {
    final err = error;
    if (err != null) throw err;
    return result!;
  }
}

class _ThrowingApiClient extends ApiClient {
  _ThrowingApiClient(this.error);

  final ApiException error;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    bool skipAuthRefresh = false,
  }) async {
    throw error;
  }
}

void main() {
  group('PurchaseRepositoryImpl', () {
    test('returns Right(pending with checkoutUrl) for paid course', () async {
      final datasource = _FakePurchaseRemoteDataSource(
        result: const PurchaseResult(
          status: 'pending',
          checkoutUrl: 'https://pay.example/checkout',
        ),
      );
      final repo = PurchaseRepositoryImpl(
        remoteDataSource: datasource,
        networkInfo: _FakeNetworkInfo(),
      );

      final result = await repo.purchaseCourse('course-1');

      expect(result.isRight(), isTrue);
      final purchase = result.getOrElse(() => throw Exception());
      expect(purchase.needsCheckout, isTrue);
      expect(purchase.checkoutUrl, 'https://pay.example/checkout');
    });

    test('returns Right(completed) for free course', () async {
      final datasource = _FakePurchaseRemoteDataSource(
        result: const PurchaseResult(status: 'completed'),
      );
      final repo = PurchaseRepositoryImpl(
        remoteDataSource: datasource,
        networkInfo: _FakeNetworkInfo(),
      );

      final result = await repo.purchaseCourse('course-free');

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => throw Exception()).isCompleted, isTrue);
    });

    test('returns Left(NetworkFailure) when offline', () async {
      final datasource = _FakePurchaseRemoteDataSource(
        result: const PurchaseResult(status: 'completed'),
      );
      final repo = PurchaseRepositoryImpl(
        remoteDataSource: datasource,
        networkInfo: _FakeNetworkInfo(connected: false),
      );

      final result = await repo.purchaseCourse('course-1');

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f, (_) => throw Exception()),
          isA<NetworkFailure>());
    });

    test('maps ServerException to Left(ServerFailure)', () async {
      final datasource = _FakePurchaseRemoteDataSource(
        error: const ServerException(message: 'boom', statusCode: 500),
      );
      final repo = PurchaseRepositoryImpl(
        remoteDataSource: datasource,
        networkInfo: _FakeNetworkInfo(),
      );

      final result = await repo.purchaseCourse('course-1');

      final failure = result.fold((f) => f, (_) => throw Exception());
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('datasource maps 409 ApiException to already_enrolled result',
        () async {
      final datasource = PurchaseRemoteDataSourceImpl(
        apiClient: _ThrowingApiClient(ApiException('Already enrolled', 409)),
      );

      final result = await datasource.purchase('course-1');

      expect(result.status, 'already_enrolled');
      expect(result.isCompleted, isTrue);
    });
  });

  group('PurchaseCubit', () {
    PurchaseCubit buildCubit(_FakePurchaseRemoteDataSource datasource) {
      final repo = PurchaseRepositoryImpl(
        remoteDataSource: datasource,
        networkInfo: _FakeNetworkInfo(),
      );
      return PurchaseCubit(
        purchaseCourseUseCase: PurchaseCourseUseCase(repo),
      );
    }

    blocTest<PurchaseCubit, PurchaseState>(
      'emits [loading, checkoutRequired] when paid course needs checkout',
      build: () => buildCubit(
        _FakePurchaseRemoteDataSource(
          result: const PurchaseResult(
            status: 'pending',
            checkoutUrl: 'https://pay.example/checkout',
          ),
        ),
      ),
      act: (cubit) => cubit.purchase('course-paid'),
      expect: () => const [
        PurchaseLoading(),
        PurchaseCheckoutRequired('https://pay.example/checkout'),
      ],
    );

    blocTest<PurchaseCubit, PurchaseState>(
      'emits [loading, enrolled] for free course',
      build: () => buildCubit(
        _FakePurchaseRemoteDataSource(
          result: const PurchaseResult(status: 'completed'),
        ),
      ),
      act: (cubit) => cubit.purchase('course-free'),
      expect: () => const [
        PurchaseLoading(),
        PurchaseEnrolled(),
      ],
    );

    blocTest<PurchaseCubit, PurchaseState>(
      'emits [loading, enrolled] when already enrolled (409 passthrough)',
      build: () => buildCubit(
        _FakePurchaseRemoteDataSource(
          result: const PurchaseResult(status: 'already_enrolled'),
        ),
      ),
      act: (cubit) => cubit.purchase('course-1'),
      expect: () => const [
        PurchaseLoading(),
        PurchaseEnrolled(message: 'Already enrolled in this course'),
      ],
    );

    blocTest<PurchaseCubit, PurchaseState>(
      'emits [loading, error] when repository fails',
      build: () => buildCubit(
        _FakePurchaseRemoteDataSource(
          error: const ServerException(message: 'boom', statusCode: 500),
        ),
      ),
      act: (cubit) => cubit.purchase('course-1'),
      expect: () => const [
        PurchaseLoading(),
        PurchaseError('boom'),
      ],
    );
  });
}
