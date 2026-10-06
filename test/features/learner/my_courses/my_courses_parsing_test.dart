import 'package:flutter_test/flutter_test.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/learner/my_courses/data/datasources/my_courses_remote_datasource.dart';
import 'package:lms/features/shared/data/models/course_model.dart';
import 'package:lms/features/shared/data/models/my_course_detail_model.dart';

class _StubApiClient extends ApiClient {
  _StubApiClient(this._response);

  final Map<String, dynamic> _response;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool skipAuthRefresh = false,
  }) async {
    return _response;
  }
}

/// Real payload captured from the live API (2026-10-06): list items are
/// **purchase records** with the course nested under `course`, camelCase
/// timestamps, nullable `thumbnailUrl`/`kashier*` fields, and `meta` with
/// `sortBy`.
Map<String, dynamic> _realMyCoursesPayload() => {
      'data': [
        {
          'id': '17a9ce98-dc06-47ea-87c7-e3ffff4ab542',
          'createdAt': '2026-10-06T13:05:30.982Z',
          'updatedAt': '2026-10-06T13:05:30.982Z',
          'deletedAt': null,
          'studentId': '50f833b1-82bd-400a-8d3f-bfe10940fa81',
          'courseId': 'e7354d12-8ab6-4854-989d-c47d9fde3e60',
          'amount': '0.00',
          'platformCommission': '0.00',
          'teacherRevenue': '0.00',
          'currency': 'egp',
          'kashierOrderId': null,
          'kashierPaymentId': null,
          'status': 'completed',
          'purchasedAt': '2026-10-06T13:05:30.942Z',
          'course': {
            'id': 'e7354d12-8ab6-4854-989d-c47d9fde3e60',
            'createdAt': '2026-09-16T14:03:00.048Z',
            'updatedAt': '2026-09-16T14:03:00.048Z',
            'deletedAt': null,
            'title': 'Introduction to Computer Science',
            'description': 'Free starter course for all students',
            'price': '0.00',
            'currency': 'egp',
            'categoryId': '9f8d9c81-e83d-42bf-88c9-63a4b8345e14',
            'category': {
              'id': '9f8d9c81-e83d-42bf-88c9-63a4b8345e14',
              'name': 'Business Administration & Commerce',
              'nameAr': 'إدارة الأعمال والتجارة',
              'slug': 'business-commerce',
              'isActive': true,
            },
            'thumbnailUrl': null,
            'isActive': true,
            'instructorId': '0131c95f-461c-4f0b-8024-a131a1a48581',
            'instructor': {
              'id': '0131c95f-461c-4f0b-8024-a131a1a48581',
              'firstName': 'Taha',
              'lastName': 'Hussein',
              'role': 'instructor',
              'profileImageUrl': null,
            },
          },
        },
      ],
      'meta': {
        'itemsPerPage': 10,
        'totalItems': 1,
        'currentPage': 1,
        'totalPages': 1,
        'sortBy': [
          ['purchasedAt', 'DESC'],
        ],
      },
      'links': {
        'current':
            'http://lms-production-1a72.up.railway.app/api/learner/my-courses?page=1&limit=10&sortBy=purchasedAt:DESC',
      },
    };

void main() {
  group('MyCoursesRemoteDataSource (GET /learner/my-courses)', () {
    test('parses real payload: purchase items unwrap nested course', () async {
      final ds = MyCoursesRemoteDataSourceImpl(
        apiClient: _StubApiClient(_realMyCoursesPayload()),
      );

      final response = await ds.getMyCourses();

      expect(response.data, hasLength(1));
      final course = response.data.single;
      expect(course.id, 'e7354d12-8ab6-4854-989d-c47d9fde3e60');
      expect(course.title, 'Introduction to Computer Science');
      expect(course.description, 'Free starter course for all students');
      expect(course.thumbnailUrl, isNull);
      expect(course.instructor?.firstName, 'Taha');
      expect(course.instructor?.lastName, 'Hussein');
      expect(response.meta.totalItems, 1);
      expect(response.meta.currentPage, 1);
      expect(response.meta.totalPages, 1);
      expect(response.meta.itemsPerPage, 10);
    });

    test('still parses plain course objects (no purchase wrapper)', () async {
      final ds = MyCoursesRemoteDataSourceImpl(
        apiClient: _StubApiClient({
          'data': [
            {
              'id': 'course-1',
              'title': 'Plain course',
              'description': 'desc',
              'thumbnailUrl': null,
            },
          ],
          'meta': {'itemsPerPage': 10, 'totalItems': 1, 'currentPage': 1, 'totalPages': 1},
        }),
      );

      final response = await ds.getMyCourses();

      expect(response.data.single.id, 'course-1');
      expect(response.data.single.title, 'Plain course');
    });
  });

  group('CourseModel.fromJson', () {
    test('parses camelCase createdAt and null-safe required fields', () {
      final model = CourseModel.fromJson(const {
        'id': 'c1',
        'title': 'T',
        'description': 'D',
        'createdAt': '2026-09-16T14:03:00.048Z',
        'thumbnailUrl': null,
      });

      expect(model.createdAt, isNotNull);
      expect(model.createdAt!.year, 2026);
    });

    test('tolerates missing title/description without throwing', () {
      final model = CourseModel.fromJson(const {'id': 'c2'});
      expect(model.id, 'c2');
      expect(model.title, '');
      expect(model.description, '');
    });
  });

  group('MyCourseDetailModel.fromJson', () {
    test('unwraps purchase-wrapped course', () {
      final detail = MyCourseDetailModel.fromJson({
        'id': 'purchase-1',
        'status': 'completed',
        'course': {
          'id': 'c9',
          'title': 'Wrapped course',
          'description': 'desc',
          'thumbnailUrl': null,
        },
      });

      expect(detail.course.id, 'c9');
      expect(detail.course.title, 'Wrapped course');
      expect(detail.contents, isEmpty);
    });
  });
}
