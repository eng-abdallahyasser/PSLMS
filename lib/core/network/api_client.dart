import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;
import 'package:lms/core/constants/app_constants.dart';

class ApiClient {
  String _baseUrl = AppConstants.baseUrl;

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) => _baseUrl = url;

  late final http.Client _client = http_io.IOClient(
    HttpClient()
      ..connectionTimeout = const Duration(seconds: 15)
      ..idleTimeout = const Duration(seconds: 15),
  );

  String? Function()? _tokenProvider;
  String _languageCode = 'ar';

  Future<String?> Function()? onTokenRefresh;
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  void setTokenProvider(String? Function()? tokenProvider) {
    _tokenProvider = tokenProvider;
  }

  void setLanguageCode(String code) {
    _languageCode = code;
  }

  String? get _token => _tokenProvider?.call();

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept-Language': _languageCode,
    };
    final token = _token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final url = Uri.parse('$baseUrl$path');
    if (queryParameters == null || queryParameters.isEmpty) return url;
    return url.replace(
      queryParameters: queryParameters.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      ),
    );
  }

  bool _isAuthPath(String path) => path.startsWith('/auth/');

  Future<bool> _handleRefresh() async {
    if (_isRefreshing && _refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();
    try {
      final newToken = await onTokenRefresh?.call();
      final ok = newToken != null && newToken.isNotEmpty;
      _refreshCompleter!.complete(ok);
      return ok;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<http.Response> _retryRequest(http.Request request) async {
    final retriedRequest = http.Request(request.method, request.url);
    retriedRequest.headers.addAll(_headers);
    if (request.body.isNotEmpty) {
      retriedRequest.body = request.body;
    }
    final streamedResponse = await _client.send(retriedRequest);
    return http.Response.fromStream(streamedResponse);
  }

  Map<String, String> _mergeHeaders(Map<String, String>? extra) {
    if (extra == null || extra.isEmpty) return _headers;
    return <String, String>{..._headers, ...extra};
  }

  String _formatRequestBody(dynamic data) {
    if (data == null) return '';
    if (data is Map) return jsonEncode(data);
    return data.toString();
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    log('[API] GET $path');
    final url = _buildUri(path, queryParameters);
    final request = http.Request('GET', url);
    request.headers.addAll(_headers);
    final streamedResponse = await _client.send(request);
    var response = await http.Response.fromStream(streamedResponse);
    log('[API] GET $path: ${response.statusCode} ${response.body}');

    if (response.statusCode == 401 &&
        onTokenRefresh != null &&
        !_isAuthPath(path)) {
      final refreshed = await _handleRefresh();
      if (refreshed) {
        response = await _retryRequest(request);
        log('[API] GET $path (retry): ${response.statusCode} ${response.body}');
      }
    }
    return _handleResponse(response);
  }
    Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    log('[API] GET $path');
    final url = _buildUri(path, queryParameters);
    final request = http.Request('GET', url);
    request.headers.addAll(_headers);
    final streamedResponse = await _client.send(request);
    var response = await http.Response.fromStream(streamedResponse);
    log('[API] GET $path: ${response.statusCode} ${response.body}');

    if (response.statusCode == 401 &&
        onTokenRefresh != null &&
        !_isAuthPath(path)) {
      final refreshed = await _handleRefresh();
      if (refreshed) {
        response = await _retryRequest(request);
        log('[API] GET $path (retry): ${response.statusCode} ${response.body}');
      }
    }
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, String>? headers,
    bool skipAuthRefresh = false,
  }) async {
    log('[API] POST $path: ${_formatRequestBody(data)}');
    final url = _buildUri(path);
    final request = http.Request('POST', url);
    request.headers.addAll(_mergeHeaders(headers));
    if (data != null) request.body = _formatRequestBody(data);
    final streamedResponse = await _client.send(request);
    var response = await http.Response.fromStream(streamedResponse);
    log('[API] POST $path: ${response.statusCode} ${response.body}');

    if (!skipAuthRefresh &&
        response.statusCode == 401 &&
        onTokenRefresh != null &&
        !_isAuthPath(path)) {
      final refreshed = await _handleRefresh();
      if (refreshed) {
        response = await _retryRequest(request);
        log('[API] POST $path (retry): ${response.statusCode} ${response.body}');
      }
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    log('[API] PATCH $path: ${_formatRequestBody(data)}');
    final url = _buildUri(path);
    final request = http.Request('PATCH', url);
    request.headers.addAll(_mergeHeaders(headers));
    if (data != null) request.body = _formatRequestBody(data);
    final streamedResponse = await _client.send(request);
    var response = await http.Response.fromStream(streamedResponse);
    log('[API] PATCH $path: ${response.statusCode} ${response.body}');

    if (response.statusCode == 401 &&
        onTokenRefresh != null &&
        !_isAuthPath(path)) {
      final refreshed = await _handleRefresh();
      if (refreshed) {
        response = await _retryRequest(request);
        log('[API] PATCH $path (retry): ${response.statusCode} ${response.body}');
      }
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
  }) async {
    log('[API] DELETE $path: ${_formatRequestBody(data)}');
    final url = _buildUri(path);
    final request = http.Request('DELETE', url);
    request.headers.addAll(_headers);
    if (data != null) request.body = _formatRequestBody(data);
    final streamedResponse = await _client.send(request);
    var response = await http.Response.fromStream(streamedResponse);
    log('[API] DELETE $path: ${response.statusCode} ${response.body}');

    if (response.statusCode == 401 &&
        onTokenRefresh != null &&
        !_isAuthPath(path)) {
      final refreshed = await _handleRefresh();
      if (refreshed) {
        response = await _retryRequest(request);
        log('[API] DELETE $path (retry): ${response.statusCode} ${response.body}');
      }
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    log('[API] UPLOAD $path: $filePath');
    final request = http.MultipartRequest(
      method,
      _buildUri(path),
    );
    request.headers.addAll(_mergeHeaders(headers));
    if (fields != null) request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    log('[API] UPLOAD $path: ${response.statusCode} ${response.body}');
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw ApiException.fromEnvelope(data, response.statusCode);
  }

  List<dynamic> _handleListResponse(http.Response response) {
    final data = response.body.isNotEmpty
        ? jsonDecode(response.body) as List<dynamic>
        : <dynamic>[];

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = data.isNotEmpty && data.first is Map
        ? (data.first as Map<String, dynamic>)['message'] as String?
        : 'Request failed (${response.statusCode})';
    throw ApiException(
      message ?? 'Request failed (${response.statusCode})',
      response.statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;
  final String? error;
  final String? requiredAction;
  final String? actionRoute;
  final List<String>? availableActions;
  final String? conflictId;
  final String? projectedAvailableAt;
  final List<ApiFieldError>? fieldErrors;
  final String? phoneVerificationUserId;

  ApiException(
    this.message,
    this.statusCode, {
    this.code,
    this.error,
    this.requiredAction,
    this.actionRoute,
    this.availableActions,
    this.conflictId,
    this.projectedAvailableAt,
    this.fieldErrors,
    this.phoneVerificationUserId,
  });

  factory ApiException.fromEnvelope(
    Map<String, dynamic> json,
    int statusCode,
  ) {
    final message =
        json['message'] as String? ?? 'Request failed ($statusCode)';
    final errors = json['errors'] as List<dynamic>?;
    final availableActions = json['availableActions'] as List<dynamic>?;
    final verification = json['verification'] as Map<String, dynamic>?;
    return ApiException(
      message,
      statusCode,
      code: json['code'] as String?,
      error: json['error'] as String?,
      requiredAction: json['requiredAction'] as String?,
      actionRoute: json['actionRoute'] as String?,
      availableActions: availableActions?.whereType<String>().toList(),
      conflictId: json['conflictId'] as String?,
      projectedAvailableAt: json['projectedAvailableAt'] as String?,
      phoneVerificationUserId:
          verification?['userId'] as String? ?? json['userId'] as String?,
      fieldErrors: errors
          ?.map((e) => ApiFieldError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isPhoneNotVerified => code == 'AUTH_PHONE_NOT_VERIFIED';

  bool get hasRequiredAction =>
      requiredAction != null && requiredAction!.isNotEmpty;

  @override
  String toString() => message;
}

class ApiFieldError {
  final String field;
  final List<String> messages;

  const ApiFieldError({required this.field, required this.messages});

  factory ApiFieldError.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] as List<dynamic>?;
    return ApiFieldError(
      field: json['field'] as String? ?? '',
      messages: messages?.whereType<String>().toList() ?? const [],
    );
  }
}
