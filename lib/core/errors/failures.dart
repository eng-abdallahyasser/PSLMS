import 'package:equatable/equatable.dart';

/// Abstract base class for all failures.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure originating from server errors.
class ServerFailure extends Failure {
  final int? statusCode;
  final dynamic data;

  const ServerFailure({
    required String message,
    this.statusCode,
    this.data,
  }) : super(message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Failure due to network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
      : super(message);
}

/// Failure from cache/storage operations.
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache operation failed'])
      : super(message);
}

/// Failure from authentication errors.
class AuthFailure extends Failure {
  final int? statusCode;

  const AuthFailure({
    required String message,
    this.statusCode,
  }) : super(message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Failure from input validation errors.
class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure({
    required String message,
    this.errors,
  }) : super(message);

  @override
  List<Object> get props => [message, errors ?? {}];
}
