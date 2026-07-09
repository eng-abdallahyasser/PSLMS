import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class ListStudentsUseCase {

  ListStudentsUseCase(this.repository);
  final StudentRepository repository;

  Future<Either<Failure, PaginatedStudents>> call(ListStudentsParams params) {
    return repository.listStudents(
      status: params.status,
      page: params.page,
      limit: params.limit,
    );
  }
}

class ListStudentsParams extends Equatable {

  const ListStudentsParams({
    this.status,
    this.page = 1,
    this.limit = 10,
  });
  final String? status;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [status, page, limit];
}
