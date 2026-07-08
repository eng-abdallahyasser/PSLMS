import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructors/domain/entities/invitation_info_entity.dart';
import 'package:lms/features/instructors/domain/repositories/instructor_repository.dart';

class GetInvitationInfoUseCase {
  final InstructorRepository repository;

  GetInvitationInfoUseCase(this.repository);

  Future<Either<Failure, InvitationInfoEntity>> call(String token) {
    return repository.getInvitationInfo(token);
  }
}
