import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/models/paginated_result.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/core/network/network_info.dart';
import 'package:lms/features/learner/instructors/data/models/instructor_profile_model.dart';
import 'package:lms/features/shared/data/models/course_model.dart';
import 'package:lms/features/shared/discovery/data/datasources/discovery_remote_datasource.dart';
import 'package:lms/features/shared/discovery/data/models/category_model.dart';
import 'package:lms/features/shared/discovery/data/repositories/discovery_repository_impl.dart';
import 'package:lms/features/shared/discovery/domain/entities/category_entity.dart';
import 'package:lms/features/shared/discovery/domain/repositories/discovery_repository.dart';
import 'package:lms/features/shared/discovery/domain/usecases/get_categories_usecase.dart';
import 'package:lms/features/shared/discovery/domain/usecases/get_public_courses_usecase.dart';

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo({this.connected = true});
  final bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<InternetConnectionStatus> get onStatusChange => const Stream.empty();
}

class _StubApiClient extends ApiClient {
  _StubApiClient({
    this.pagedResults = const {},
    this.getResponses = const {},
    this.error,
  });

  final Map<String, PaginatedResult<Map<String, dynamic>>> pagedResults;
  final Map<String, Map<String, dynamic>> getResponses;
  final ApiException? error;
  final List<String> calls = [];

  void _maybeThrow() {
    final err = error;
    if (err != null) throw err;
  }

  @override
  Future<PaginatedResult<Map<String, dynamic>>> getPaged(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    calls.add(path);
    _maybeThrow();
    return pagedResults[path]!;
  }

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool skipAuthRefresh = false,
  }) async {
    calls.add(path);
    _maybeThrow();
    return getResponses[path]!;
  }
}

class _FakeDiscoveryRemoteDataSource implements DiscoveryRemoteDataSource {
  _FakeDiscoveryRemoteDataSource({this.error});

  Object? error;

  void _throw() {
    final err = error;
    if (err != null) throw err;
  }

  @override
  Future<List<CourseModel>> getPublicCourses({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    _throw();
    return [];
  }

  @override
  Future<CourseModel> getPublicCourse(String id) async {
    _throw();
    throw UnimplementedError();
  }

  @override
  Future<List<InstructorProfileModel>> getPublicInstructors({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    _throw();
    return [];
  }

  @override
  Future<InstructorProfileModel> getPublicInstructor(String id) async {
    _throw();
    throw UnimplementedError();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    _throw();
    return [];
  }
}

PaginatedResult<Map<String, dynamic>> _paged(List<Map<String, dynamic>> items) {
  return PaginatedResult<Map<String, dynamic>>(
    items: items,
    meta: const PageMeta(),
  );
}

Map<String, dynamic> _courseJson({String id = 'course-1', String title = 'Flutter'}) {
  return {'id': id, 'title': title, 'description': 'desc'};
}

void main() {
  group('DiscoveryRemoteDataSource', () {
    test('getPublicCourses parses paged envelope', () async {
      final client = _StubApiClient(pagedResults: {
        '/public/courses': _paged([_courseJson(), _courseJson(id: 'course-2', title: 'Dart')]),
      });
      final ds = DiscoveryRemoteDataSourceImpl(apiClient: client);

      final courses = await ds.getPublicCourses(page: 2, limit: 5, search: 'fl');

      expect(courses, hasLength(2));
      expect(courses.first.title, 'Flutter');
      expect(client.calls, ['/public/courses']);
    });

    test('getPublicCourse fetches single course by id', () async {
      final client = _StubApiClient(getResponses: {
        '/public/courses/course-9': _courseJson(id: 'course-9', title: 'Advanced'),
      });
      final ds = DiscoveryRemoteDataSourceImpl(apiClient: client);

      final course = await ds.getPublicCourse('course-9');

      expect(course.id, 'course-9');
      expect(course.title, 'Advanced');
      expect(client.calls, ['/public/courses/course-9']);
    });

    test('getPublicInstructors parses instructor items', () async {
      final client = _StubApiClient(pagedResults: {
        '/public/instructors': _paged([
          {'id': 'inst-1', 'firstName': 'Sara', 'lastName': 'Ali'},
        ]),
      });
      final ds = DiscoveryRemoteDataSourceImpl(apiClient: client);

      final instructors = await ds.getPublicInstructors();

      expect(instructors, hasLength(1));
      expect(instructors.first.fullName, 'Sara Ali');
    });

    test('getCategories handles plain array responses', () async {
      final client = _StubApiClient(pagedResults: {
        '/public/categories': _paged([
          {'id': 'cat-1', 'name': 'Programming', 'nameAr': 'برمجة', 'slug': 'programming'},
        ]),
      });
      final ds = DiscoveryRemoteDataSourceImpl(apiClient: client);

      final categories = await ds.getCategories();

      expect(categories, hasLength(1));
      expect(categories.first.name, 'Programming');
      expect(categories.first.nameAr, 'برمجة');
      expect(categories.first.slug, 'programming');
    });

    test('maps ApiException to ServerException with status', () async {
      final client = _StubApiClient(
        error: ApiException('Not found', 404),
      );
      final ds = DiscoveryRemoteDataSourceImpl(apiClient: client);

      expect(
        () => ds.getPublicCourse('missing'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having((e) => e.message, 'message', 'Not found'),
        ),
      );
    });
  });

  group('DiscoveryRepositoryImpl', () {
    test('returns Right(courses) on success', () async {
      final repo = DiscoveryRepositoryImpl(
        remoteDataSource: _FakeDiscoveryRemoteDataSource(),
        networkInfo: _FakeNetworkInfo(),
      );

      final result = await repo.getPublicCourses();

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => throw Exception()), isEmpty);
    });

    test('returns NetworkFailure when offline', () async {
      final repo = DiscoveryRepositoryImpl(
        remoteDataSource: _FakeDiscoveryRemoteDataSource(),
        networkInfo: _FakeNetworkInfo(connected: false),
      );

      final result = await repo.getCategories();

      expect(result.isLeft(), isTrue);
    });

    test('maps ServerException to ServerFailure', () async {
      final repo = DiscoveryRepositoryImpl(
        remoteDataSource: _FakeDiscoveryRemoteDataSource(
          error: const ServerException(message: 'Boom', statusCode: 500),
        ),
        networkInfo: _FakeNetworkInfo(),
      );

      final result = await repo.getPublicInstructors();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.message, 'Boom'),
        (_) => fail('expected failure'),
      );
    });
  });

  group('Discovery usecases', () {
    late DiscoveryRepository repository;

    setUp(() {
      repository = DiscoveryRepositoryImpl(
        remoteDataSource: _FakeDiscoveryRemoteDataSource(),
        networkInfo: _FakeNetworkInfo(),
      );
    });

    test('GetPublicCoursesUseCase delegates to repository', () async {
      final usecase = GetPublicCoursesUseCase(repository);

      final result = await usecase(limit: 7);

      expect(result.isRight(), isTrue);
    });

    test('GetCategoriesUseCase delegates to repository', () async {
      final usecase = GetCategoriesUseCase(repository);

      final result = await usecase();

      expect(result.getOrElse(() => throw Exception()), isA<List<CategoryEntity>>());
    });
  });
}
