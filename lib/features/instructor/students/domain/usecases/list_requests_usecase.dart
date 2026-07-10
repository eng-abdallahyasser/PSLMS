import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class ListRequestsUseCase {

  ListRequestsUseCase(this.repository);
  final StudentRepository repository;

  Future<Either<Failure, PaginatedStudents>> call(ListRequestsParams params) {
    return repository.listRequests(
      page: params.page,
      limit: params.limit,
    );
  }
}

class ListRequestsParams extends Equatable {

  const ListRequestsParams({this.page = 1, this.limit = 10});
  final int page;
  final int limit;

  @override
  List<Object> get props => [page, limit];
}
