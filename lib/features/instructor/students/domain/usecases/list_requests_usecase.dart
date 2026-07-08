import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/entities/student_entity.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class ListRequestsUseCase {
  final StudentRepository repository;

  ListRequestsUseCase(this.repository);

  Future<Either<Failure, PaginatedStudents>> call(ListRequestsParams params) {
    return repository.listRequests(
      page: params.page,
      limit: params.limit,
    );
  }
}

class ListRequestsParams extends Equatable {
  final int page;
  final int limit;

  const ListRequestsParams({this.page = 1, this.limit = 10});

  @override
  List<Object> get props => [page, limit];
}
