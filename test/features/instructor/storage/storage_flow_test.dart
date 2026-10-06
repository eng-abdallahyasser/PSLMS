import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/instructor/storage/data/datasources/storage_remote_datasource.dart';
import 'package:lms/features/instructor/storage/data/repositories/storage_repository_impl.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';
import 'package:lms/features/instructor/storage/domain/repositories/storage_repository.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_revenue_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_storage_plans_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/get_storage_usage_usecase.dart';
import 'package:lms/features/instructor/storage/domain/usecases/subscribe_storage_plan_usecase.dart';
import 'package:lms/features/instructor/storage/presentation/cubit/storage_cubit.dart';

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo({this.connected = true});
  final bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<InternetConnectionStatus> get onStatusChange => const Stream.empty();
}

class _FakeStorageRemoteDataSource implements StorageRemoteDataSource {
  _FakeStorageRemoteDataSource({
    this.usage,
    this.plans,
    this.subscribeResult,
    this.revenue,
    this.error,
  });

  StorageUsage? usage;
  List<StoragePlan>? plans;
  SubscribeResult? subscribeResult;
  RevenueSummary? revenue;
  Object? error;
  String? lastPlanId;

  void _throw() {
    final err = error;
    if (err != null) throw err;
  }

  @override
  Future<StorageUsage> getUsage() async {
    _throw();
    return usage!;
  }

  @override
  Future<List<StoragePlan>> getPlans() async {
    _throw();
    return plans!;
  }

  @override
  Future<SubscribeResult> subscribe(String planId) async {
    _throw();
    lastPlanId = planId;
    return subscribeResult!;
  }

  @override
  Future<RevenueSummary> getRevenue() async {
    _throw();
    return revenue!;
  }
}

class _StubApiClient extends ApiClient {
  _StubApiClient({
    this.getResponses = const {},
    this.postResponse,
    this.postError,
  });

  final Map<String, Map<String, dynamic>> getResponses;
  final Map<String, dynamic>? postResponse;
  final ApiException? postError;
  final List<String> getCalls = [];
  final List<String> postCalls = [];
  final List<dynamic> postData = [];

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool skipAuthRefresh = false,
  }) async {
    getCalls.add(path);
    return getResponses[path]!;
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    bool skipAuthRefresh = false,
  }) async {
    postCalls.add(path);
    postData.add(data);
    final err = postError;
    if (err != null) throw err;
    return postResponse ?? const {};
  }
}

StorageRepositoryImpl _repo(StorageRemoteDataSource datasource) {
  return StorageRepositoryImpl(
    remoteDataSource: datasource,
    networkInfo: _FakeNetworkInfo(),
  );
}

StorageCubit _cubit(StorageRepository repository) {
  return StorageCubit(
    getUsageUseCase: GetStorageUsageUseCase(repository),
    getPlansUseCase: GetStoragePlansUseCase(repository),
    subscribeUseCase: SubscribeStoragePlanUseCase(repository),
    getRevenueUseCase: GetRevenueUseCase(repository),
  );
}

void main() {
  group('StorageRemoteDataSource', () {
    test('getUsage parses tolerant keys', () async {
      final client = _StubApiClient(getResponses: {
        '/instructor/storage/usage': {
          'effectiveQuotaBytes': 5368709120,
          'usedBytes': 1073741824,
          'activeSubscriptions': [
            {'id': 'sub-1'},
            {'id': 'sub-2'},
          ],
        },
      });
      final ds = StorageRemoteDataSourceImpl(apiClient: client);

      final usage = await ds.getUsage();

      expect(usage.quotaBytes, 5368709120);
      expect(usage.usedBytes, 1073741824);
      expect(usage.activeSubscriptions, 2);
      expect(usage.usedPercentage, closeTo(20, 0.01));
    });

    test('getPlans handles envelope and plain array', () async {
      final client = _StubApiClient(getResponses: {
        '/instructor/storage/plans': {
          'data': [
            {
              'id': 'plan-1',
              'name': '50 GB',
              'nameAr': '٥٠ جيجا',
              'gigabytes': 50,
              'price': 100,
              'durationDays': 90,
            },
          ],
        },
      });
      final ds = StorageRemoteDataSourceImpl(apiClient: client);

      final plans = await ds.getPlans();

      expect(plans, hasLength(1));
      expect(plans.first.id, 'plan-1');
      expect(plans.first.gigabytes, 50);
      expect(plans.first.price, 100);
    });

    test('subscribe posts planId and parses checkoutUrl', () async {
      final client = _StubApiClient(
        postResponse: {'checkoutUrl': 'https://pay.example/session-1'},
      );
      final ds = StorageRemoteDataSourceImpl(apiClient: client);

      final result = await ds.subscribe('plan-1');

      expect(client.postCalls, ['/instructor/storage/subscribe']);
      expect(client.postData.single, {'planId': 'plan-1'});
      expect(result.checkoutUrl, 'https://pay.example/session-1');
    });

    test('subscribe maps ApiException to ServerException', () async {
      final client = _StubApiClient(
        postError: ApiException('Plan not found', 404),
      );
      final ds = StorageRemoteDataSourceImpl(apiClient: client);

      expect(
        () => ds.subscribe('bad'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', 'Plan not found'),
        ),
      );
    });

    test('getRevenue parses summary', () async {
      final client = _StubApiClient(getResponses: {
        '/instructor/revenue': {
          'totalSales': 12,
          'grossRevenue': 1200.5,
          'totalCommission': 120.5,
          'netRevenue': 1080.0,
        },
      });
      final ds = StorageRemoteDataSourceImpl(apiClient: client);

      final revenue = await ds.getRevenue();

      expect(revenue.totalSales, 12);
      expect(revenue.grossRevenue, 1200.5);
      expect(revenue.totalCommission, 120.5);
      expect(revenue.netRevenue, 1080.0);
    });
  });

  group('StorageRepositoryImpl', () {
    test('returns Right(usage) on success', () async {
      final repo = _repo(_FakeStorageRemoteDataSource(
        usage: const StorageUsage(quotaBytes: 100, usedBytes: 25),
      ));

      final result = await repo.getUsage();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => throw Exception()).usedBytes, 25);
    });

    test('returns NetworkFailure when offline', () async {
      final repo = StorageRepositoryImpl(
        remoteDataSource: _FakeStorageRemoteDataSource(
          usage: const StorageUsage(quotaBytes: 1, usedBytes: 1),
        ),
        networkInfo: _FakeNetworkInfo(connected: false),
      );

      final result = await repo.getUsage();

      expect(result.isLeft(), isTrue);
    });

    test('maps ServerException to ServerFailure', () async {
      final repo = _repo(_FakeStorageRemoteDataSource(
        error: ServerException(message: 'Boom', statusCode: 500),
      ));

      final result = await repo.getRevenue();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) {
          expect(f.message, 'Boom');
        },
        (_) => fail('expected failure'),
      );
    });
  });

  group('StorageCubit', () {
    late StorageRepository repository;

    setUp(() {
      repository = _repo(_FakeStorageRemoteDataSource(
        usage: const StorageUsage(
          quotaBytes: 100,
          usedBytes: 50,
          activeSubscriptions: 1,
        ),
        plans: const [
          StoragePlan(
            id: 'plan-1',
            name: '50 GB',
            gigabytes: 50,
            price: 100,
          ),
        ],
        subscribeResult:
            const SubscribeResult(checkoutUrl: 'https://pay.example/x'),
        revenue: const RevenueSummary(totalSales: 3, netRevenue: 300),
      ));
    });

    blocTest<StorageCubit, StorageState>(
      'load emits Loading then Loaded',
      build: () => _cubit(repository),
      act: (cubit) => cubit.load(),
      expect: () => [
        const StorageLoading(),
        isA<StorageLoaded>()
            .having((s) => s.usage.usedBytes, 'usage.usedBytes', 50)
            .having((s) => s.plans.first.id, 'plans.first.id', 'plan-1')
            .having((s) => s.revenue?.totalSales, 'revenue.totalSales', 3),
      ],
    );

    blocTest<StorageCubit, StorageState>(
      'load emits Error when datasource fails',
      build: () {
        final failing = _repo(_FakeStorageRemoteDataSource(
          error: ServerException(message: 'Nope', statusCode: 500),
        ));
        return _cubit(failing);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const StorageLoading(),
        const StorageError('Nope'),
      ],
    );

    blocTest<StorageCubit, StorageState>(
      'subscribe emits checkout url',
      build: () => _cubit(repository),
      act: (cubit) => cubit.subscribe('plan-1'),
      expect: () => [
        const StorageSubscribeCheckout('https://pay.example/x'),
      ],
    );

    blocTest<StorageCubit, StorageState>(
      'subscribe emits Error when backend rejects',
      build: () {
        final failing = _repo(_FakeStorageRemoteDataSource(
          plans: const <StoragePlan>[],
          error: ServerException(
            message: 'Quota exceeded',
            statusCode: 413,
          ),
        ));
        return _cubit(failing);
      },
      act: (cubit) => cubit.subscribe('plan-1'),
      expect: () => [const StorageError('Quota exceeded')],
    );
  });
}
