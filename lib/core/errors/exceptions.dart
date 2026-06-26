/// Base class for all server-related exceptions.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Exception for network/unreachability issues.
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for cache/storage related failures.
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache operation failed']);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception for authentication failures (401, 403).
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AuthException: $message (status: $statusCode)';
}

/// Exception for validation errors.
class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  const ValidationException({
    required this.message,
    this.errors,
  });

  @override
  String toString() => 'ValidationException: $message';
}
