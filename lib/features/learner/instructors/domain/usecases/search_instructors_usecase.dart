import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class SearchInstructorsUseCase {

  SearchInstructorsUseCase(this.repository);
  final InstructorRepository repository;

  Future<Either<Failure, List<InstructorProfileEntity>>> call({
    required String query,
    int page = 1,
    int limit = 10,
  }) {
    return repository.searchInstructors(
      query: query,
      page: page,
      limit: limit,
    );
  }
}
