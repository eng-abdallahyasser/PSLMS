class UploadSession {
  const UploadSession({
    required this.sessionId,
    required this.provider,
    required this.uploadUrl,
    required this.httpMethod,
    required this.chunkSize,
    required this.totalBytes,
    this.fields = const {},
    this.headers = const {},
    this.publicId,
  });

  final String sessionId;
  final String provider;
  final String uploadUrl;
  final String httpMethod;
  final int chunkSize;
  final int totalBytes;
  final Map<String, String> fields;
  final Map<String, String> headers;
  final String? publicId;

  factory UploadSession.fromJson(Map<String, dynamic> json) {
    return UploadSession(
      sessionId: json['sessionId'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      uploadUrl: json['uploadUrl'] as String? ?? '',
      httpMethod: (json['httpMethod'] as String? ?? 'POST').toUpperCase(),
      chunkSize: json['chunkSize'] as int? ?? 0,
      totalBytes: json['totalBytes'] as int? ?? 0,
      fields: _stringMap(json['fields']),
      headers: _stringMap(json['headers']),
      publicId: json['publicId'] as String?,
    );
  }

  static Map<String, String> _stringMap(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return const {};
  }
}

class UploadStatus {
  const UploadStatus({
    required this.sessionId,
    required this.status,
    required this.totalBytes,
    required this.uploadedBytes,
    required this.nextByteOffset,
    required this.percentage,
  });

  final String sessionId;
  final String status;
  final int totalBytes;
  final int uploadedBytes;
  final int nextByteOffset;
  final double percentage;

  bool get canResume => status == 'pending';

  factory UploadStatus.fromJson(Map<String, dynamic> json) {
    return UploadStatus(
      sessionId: json['sessionId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalBytes: json['totalBytes'] as int? ?? 0,
      uploadedBytes: json['uploadedBytes'] as int? ?? 0,
      nextByteOffset: json['nextByteOffset'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CloudinaryResult {
  const CloudinaryResult({
    required this.publicId,
    required this.secureUrl,
    required this.bytes,
    required this.resourceType,
    this.format,
  });

  final String publicId;
  final String secureUrl;
  final int bytes;
  final String resourceType;
  final String? format;

  Map<String, dynamic> toJson() {
    return {
      'publicId': publicId,
      'secureUrl': secureUrl,
      'bytes': bytes,
      'resourceType': resourceType,
      if (format != null) 'format': format,
    };
  }

  /// Parses a Cloudinary-style raw response (snake_case keys).
  factory CloudinaryResult.fromProviderResponse(
    Map<String, dynamic> json,
    String fallbackPublicId,
  ) {
    return CloudinaryResult(
      publicId: json['public_id'] as String? ?? fallbackPublicId,
      secureUrl: json['secure_url'] as String? ?? '',
      bytes: json['bytes'] as int? ?? 0,
      resourceType: json['resource_type'] as String? ?? 'raw',
      format: json['format'] as String?,
    );
  }
}
