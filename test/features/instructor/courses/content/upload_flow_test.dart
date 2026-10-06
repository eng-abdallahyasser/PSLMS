import 'package:flutter_test/flutter_test.dart';
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/core/network/api_client.dart';
import 'package:lms/features/instructor/courses/content/data/datasources/content_remote_datasource.dart';
import 'package:lms/features/instructor/courses/content/data/datasources/provider_upload_client.dart';
import 'package:lms/features/instructor/courses/content/data/models/upload_session_model.dart';

class _RecordingApiClient extends ApiClient {
  final List<String> calls = [];
  final List<Map<String, dynamic>?> postDataList = [];
  final Map<String, dynamic> responses = {};
  Object? postError;
  Object? getError;

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    bool skipAuthRefresh = false,
  }) async {
    final err = postError;
    if (err != null) throw err;
    calls.add('POST $path');
    postDataList.add(data as Map<String, dynamic>?);
    return responses['POST $path'] ?? const <String, dynamic>{};
  }

  Map<String, dynamic>? get lastPostData =>
      postDataList.isEmpty ? null : postDataList.last;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final err = getError;
    if (err != null) throw err;
    calls.add('GET $path');
    return responses['GET $path'] ?? const <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
  }) async {
    calls.add('DELETE $path');
    return responses['DELETE $path'] ?? const <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    lastPatchData = data as Map<String, dynamic>?;
    calls.add('PATCH $path');
    return responses['PATCH $path'] ?? const <String, dynamic>{};
  }

  Map<String, dynamic>? lastPatchData;
}

class _FakeProviderUploadClient implements ProviderUploadClient {
  final List<UploadSession> sessions = [];
  Object? error;

  @override
  Future<CloudinaryResult> upload({
    required UploadSession session,
    required String filePath,
    String fieldName = 'file',
  }) async {
    final err = error;
    if (err != null) throw err;
    sessions.add(session);
    return const CloudinaryResult(
      publicId: 'video/abc123',
      secureUrl: 'https://res.cloudinary.com/demo/video/upload/abc123.mp4',
      bytes: 1024,
      resourceType: 'video',
      format: 'mp4',
    );
  }
}

void main() {
  const initPath = '/instructor/courses/course-1/content/upload-session';
  const completePath = '/instructor/courses/course-1/content/complete-upload';

  Map<String, dynamic> initResponse() => const {
        'sessionId': 'sess-1',
        'provider': 'cloudinary',
        'uploadUrl': 'https://api.cloudinary.com/v1_1/demo/video/upload',
        'httpMethod': 'POST',
        'chunkSize': 10485760,
        'totalBytes': 2048,
        'fields': {'api_key': 'k', 'signature': 's'},
        'headers': {'X-Test': '1'},
        'publicId': 'video/abc123',
      };

  Map<String, dynamic> completeResponse() => const {
        'id': 'content-1',
        'title': 'Lesson 1',
        'description': 'Intro',
        'contentType': 'video',
        'size': 1024,
        'url': 'https://res.cloudinary.com/demo/video/upload/abc123.mp4',
      };

  _RecordingApiClient buildApi() {
    final api = _RecordingApiClient();
    api.responses['POST $initPath'] = initResponse();
    api.responses['POST $completePath'] = completeResponse();
    api.responses['GET /uploads/session/sess-1/status'] = const {
      'sessionId': 'sess-1',
      'status': 'pending',
      'totalBytes': 2048,
      'uploadedBytes': 512,
      'nextByteOffset': 512,
      'percentage': 25,
    };
    return api;
  }

  ContentRemoteDataSourceImpl build(
    _RecordingApiClient api,
    _FakeProviderUploadClient provider,
  ) {
    return ContentRemoteDataSourceImpl(
      apiClient: api,
      providerUploadClient: provider,
    );
  }

  group('ContentRemoteDataSourceImpl upload flow', () {
    test('orchestrates init → provider upload → complete', () async {
      final api = buildApi();
      final provider = _FakeProviderUploadClient();
      final datasource = build(api, provider);

      final content = await datasource.uploadContent(
        courseId: 'course-1',
        filePath: '/tmp/does-not-exist/video.mp4',
        title: 'Lesson 1',
        description: 'Intro',
      );

      expect(api.calls, [
        'POST $initPath',
        'POST $completePath',
      ]);
      expect(provider.sessions, hasLength(1));
      expect(provider.sessions.first.sessionId, 'sess-1');
      expect(provider.sessions.first.uploadUrl,
          'https://api.cloudinary.com/v1_1/demo/video/upload');

      // Init payload matches InitUploadSessionDto.
      final initData = api.postDataList[0];
      expect(initData, isNotNull);
      expect(initData!['fileName'], 'video.mp4');
      expect(initData['fileSize'], isA<String>());
      expect(initData['mimeType'], 'video/mp4');
      expect(initData['title'], 'Lesson 1');
      expect(initData['description'], 'Intro');

      expect(content.id, 'content-1');
      expect(content.title, 'Lesson 1');
    });

    test('complete payload carries sessionId and cloudinaryResult',
        () async {
      final api = buildApi();
      final provider = _FakeProviderUploadClient();
      final datasource = build(api, provider);

      await datasource.uploadContent(
        courseId: 'course-1',
        filePath: '/tmp/video.mp4',
        title: 'Lesson 1',
      );

      final completeData = api.postDataList[1];
      expect(completeData, isNotNull);
      expect(completeData!['sessionId'], 'sess-1');
      final result = completeData['cloudinaryResult'] as Map<String, dynamic>;
      expect(result['publicId'], 'video/abc123');
      expect(result['secureUrl'], startsWith('https://'));
      expect(result['bytes'], 1024);
      expect(result['resourceType'], 'video');
      expect(result['format'], 'mp4');
    });

    test('maps init 413 (quota exceeded) to ServerException', () async {
      final api = buildApi();
      api.postError = ApiException('Storage quota exceeded', 413);
      final provider = _FakeProviderUploadClient();
      final datasource = build(api, provider);

      await expectLater(
        datasource.uploadContent(
          courseId: 'course-1',
          filePath: '/tmp/video.mp4',
          title: 'Lesson 1',
        ),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 413)
              .having((e) => e.message, 'message', 'Storage quota exceeded'),
        ),
      );
    });

    test('propagates provider upload failure and skips complete', () async {
      final api = buildApi();
      final provider = _FakeProviderUploadClient()
        ..error = const ServerException(
          message: 'signature mismatch',
          statusCode: 400,
        );
      final datasource = build(api, provider);

      await expectLater(
        datasource.uploadContent(
          courseId: 'course-1',
          filePath: '/tmp/video.mp4',
          title: 'Lesson 1',
        ),
        throwsA(isA<ServerException>()),
      );
      expect(api.calls, ['POST $initPath']);
    });

    test('getUploadStatus parses resume offset', () async {
      final api = buildApi();
      final datasource = build(api, _FakeProviderUploadClient());

      final status = await datasource.getUploadStatus('sess-1');

      expect(api.calls, ['GET /uploads/session/sess-1/status']);
      expect(status.status, 'pending');
      expect(status.canResume, isTrue);
      expect(status.nextByteOffset, 512);
      expect(status.percentage, 25);
    });

    test('abortUpload calls DELETE on upload session', () async {
      final api = buildApi();
      final datasource = build(api, _FakeProviderUploadClient());

      await datasource.abortUpload('sess-1');

      expect(api.calls, ['DELETE /uploads/session/sess-1']);
    });

    test('reorder sends both contentIds and videoIds', () async {
      final api = buildApi();
      final datasource = build(api, _FakeProviderUploadClient());

      await datasource.reorderContent(
        courseId: 'course-1',
        contentIds: ['c2', 'c1'],
      );

      expect(api.calls, ['PATCH /instructor/courses/course-1/content/reorder']);
      expect(api.lastPatchData!['contentIds'], ['c2', 'c1']);
      expect(api.lastPatchData!['videoIds'], ['c2', 'c1']);
    });
  });

  group('UploadSession parsing', () {
    test('parses init session response', () {
      final session = UploadSession.fromJson(initResponse());
      expect(session.sessionId, 'sess-1');
      expect(session.provider, 'cloudinary');
      expect(session.httpMethod, 'POST');
      expect(session.chunkSize, 10485760);
      expect(session.fields['api_key'], 'k');
      expect(session.headers['X-Test'], '1');
      expect(session.publicId, 'video/abc123');
    });

    test('parses upload status envelope', () {
      final status = UploadStatus.fromJson(const {
        'sessionId': 'sess-1',
        'status': 'completed',
        'totalBytes': 100,
        'uploadedBytes': 100,
        'nextByteOffset': 100,
        'percentage': 100,
      });
      expect(status.status, 'completed');
      expect(status.canResume, isFalse);
      expect(status.percentage, 100);
    });
  });
}
