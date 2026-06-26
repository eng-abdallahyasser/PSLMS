/// Base class for all server-related exceptions.
class ServerException implements Exception {

  const ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });
  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Exception for network/unreachability issues.
class NetworkException implements Exception {

  const NetworkException([this.message = 'No internet connection']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for cache/storage related failures.
class CacheException implements Exception {

  const CacheException([this.message = 'Cache operation failed']);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

/// Exception for authentication failures (401, 403).
class AuthException implements Exception {

  const AuthException({
    required this.message,
    this.statusCode,
  });
  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthException: $message (status: $statusCode)';
}

/// Exception for validation errors.
class ValidationException implements Exception {

  const ValidationException({
    required this.message,
    this.errors,
  });
  final String message;
  final Map<String, dynamic>? errors;

  @override
  String toString() => 'ValidationException: $message';
}
