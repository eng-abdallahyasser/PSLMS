import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/profile/domain/repositories/profile_repository.dart';

class UpdatePreferencesUseCase {
  final ProfileRepository repository;

  UpdatePreferencesUseCase(this.repository);

  Future<Either<Failure, void>> call({
    String? lang,
    String? mode,
  }) {
    return repository.updatePreferences(lang: lang, mode: mode);
  }
}
