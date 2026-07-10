import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/entities/invitation_info_entity.dart';
import 'package:lms/features/learner/instructors/domain/repositories/instructor_repository.dart';

class GetInvitationInfoUseCase {

  GetInvitationInfoUseCase(this.repository);
  final InstructorRepository repository;

  Future<Either<Failure, InvitationInfoEntity>> call(String token) {
    return repository.getInvitationInfo(token);
  }
}
