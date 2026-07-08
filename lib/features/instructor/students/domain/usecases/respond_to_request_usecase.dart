import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class RespondToRequestUseCase {
  final StudentRepository repository;

  RespondToRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(RespondToRequestParams params) {
    return repository.respondToRequest(params.requestId, params.action);
  }
}

class RespondToRequestParams extends Equatable {
  final String requestId;
  final String action;

  const RespondToRequestParams({
    required this.requestId,
    required this.action,
  });

  @override
  List<Object> get props => [requestId, action];
}
