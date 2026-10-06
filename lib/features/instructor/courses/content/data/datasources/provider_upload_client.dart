import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lms/core/errors/exceptions.dart';
import 'package:lms/features/instructor/courses/content/data/models/upload_session_model.dart';

/// Uploads a file directly to the storage provider (e.g. Cloudinary),
/// bypassing the LMS API — called with credentials returned by
/// `POST /instructor/courses/{courseId}/content/upload-session`.
abstract class ProviderUploadClient {
  Future<CloudinaryResult> upload({
    required UploadSession session,
    required String filePath,
    String fieldName = 'file',
  });
}

class ProviderUploadClientImpl implements ProviderUploadClient {
  ProviderUploadClientImpl({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<CloudinaryResult> upload({
    required UploadSession session,
    required String filePath,
    String fieldName = 'file',
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const ServerException(message: 'File not found');
    }

    final http.Response response;
    if (session.httpMethod == 'PUT') {
      final uri = _withFieldsAsQuery(session);
      final request = http.Request('PUT', uri)
        ..headers.addAll(session.headers)
        ..bodyBytes = await file.readAsBytes();
      if (session.headers['Content-Type'] == null) {
        request.headers['Content-Type'] = 'application/octet-stream';
      }
      final streamed = await _client.send(request);
      response = await http.Response.fromStream(streamed);
    } else {
      final request = http.MultipartRequest('POST', Uri.parse(session.uploadUrl))
        ..headers.addAll(session.headers)
        ..fields.addAll(session.fields)
        ..files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      final streamed = await _client.send(request);
      response = await http.Response.fromStream(streamed);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = _errorBody(response.body, response.statusCode);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AuthException(message: body, statusCode: response.statusCode);
      }
      throw ServerException(message: body, statusCode: response.statusCode);
    }

    final decoded =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (decoded is! Map<String, dynamic>) {
      throw const ServerException(
        message: 'Unexpected provider response format',
      );
    }
    return CloudinaryResult.fromProviderResponse(
      decoded,
      session.publicId ?? '',
    );
  }

  Uri _withFieldsAsQuery(UploadSession session) {
    final uri = Uri.parse(session.uploadUrl);
    if (session.fields.isEmpty) return uri;
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...session.fields,
      },
    );
  }

  String _errorBody(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic> && error['message'] is String) {
          return error['message'] as String;
        }
        if (decoded['message'] is String) {
          return decoded['message'] as String;
        }
      }
    } catch (_) {}
    return 'Upload failed ($statusCode)';
  }
}
