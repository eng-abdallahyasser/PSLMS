import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class RespondToRequestUseCase {

  RespondToRequestUseCase(this.repository);
  final StudentRepository repository;

  Future<Either<Failure, void>> call(RespondToRequestParams params) {
    return repository.respondToRequest(params.requestId, params.action);
  }
}

class RespondToRequestParams extends Equatable {

  const RespondToRequestParams({
    required this.requestId,
    required this.action,
  });
  final String requestId;
  final String action;

  @override
  List<Object> get props => [requestId, action];
}
