import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/shared/discovery/domain/repositories/discovery_repository.dart';

class GetPublicInstructorsUseCase {
  GetPublicInstructorsUseCase(this.repository);

  final DiscoveryRepository repository;

  Future<Either<Failure, List<InstructorProfileEntity>>> call({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return repository.getPublicInstructors(
      page: page,
      limit: limit,
      search: search,
    );
  }
}
