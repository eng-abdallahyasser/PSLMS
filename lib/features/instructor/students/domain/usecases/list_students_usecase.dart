import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/entities/student_entity.dart';
import 'package:lms/features/instructor/students/domain/repositories/student_repository.dart';

class ListStudentsUseCase {
  final StudentRepository repository;

  ListStudentsUseCase(this.repository);

  Future<Either<Failure, PaginatedStudents>> call(ListStudentsParams params) {
    return repository.listStudents(
      status: params.status,
      page: params.page,
      limit: params.limit,
    );
  }
}

class ListStudentsParams extends Equatable {
  final String? status;
  final int page;
  final int limit;

  const ListStudentsParams({
    this.status,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [status, page, limit];
}
