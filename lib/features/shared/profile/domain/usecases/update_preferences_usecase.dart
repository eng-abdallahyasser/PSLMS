import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/profile/domain/repositories/profile_repository.dart';

class UpdatePreferencesUseCase {

  UpdatePreferencesUseCase(this.repository);
  final ProfileRepository repository;

  Future<Either<Failure, void>> call({
    String? lang,
    String? mode,
  }) {
    return repository.updatePreferences(lang: lang, mode: mode);
  }
}
