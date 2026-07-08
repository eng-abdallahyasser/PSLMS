import 'package:equatable/equatable.dart';

/// Abstract base class for all failures.
abstract class Failure extends Equatable {

  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

/// Failure originating from server errors.
class ServerFailure extends Failure {

  const ServerFailure({
    required String message,
    this.statusCode,
    this.data,
  }) : super(message);
  final int? statusCode;
  final dynamic data;

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Failure due to network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Failure from cache/storage operations.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed']);
}

/// Failure from authentication errors.
class AuthFailure extends Failure {

  const AuthFailure({
    required String message,
    this.statusCode,
    this.errorCode,
  }) : super(message);
  final int? statusCode;
  final String? errorCode;

  @override
  List<Object> get props => [message, statusCode ?? 0, errorCode ?? ''];
}

/// Failure from input validation errors.
class ValidationFailure extends Failure {

  const ValidationFailure({
    required String message,
    this.errors,
  }) : super(message);
  final Map<String, dynamic>? errors;

  @override
  List<Object> get props => [message, errors ?? {}];
}
