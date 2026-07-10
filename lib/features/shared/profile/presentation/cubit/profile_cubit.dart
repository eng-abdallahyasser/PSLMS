import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/profile/domain/entities/profile_entity.dart';
import 'package:lms/features/shared/profile/domain/usecases/get_profile_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/update_preferences_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/update_profile_usecase.dart';
import 'package:lms/features/shared/profile/domain/usecases/upload_avatar_usecase.dart';

// ----- States -----

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {

  const ProfileLoaded(this.profile);
  final ProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {

  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ----- Events -----

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {

  const UpdateProfileEvent({this.firstName, this.lastName});
  final String? firstName;
  final String? lastName;

  @override
  List<Object?> get props => [firstName ?? '', lastName ?? ''];
}

class UpdatePreferencesEvent extends ProfileEvent {

  const UpdatePreferencesEvent({this.lang, this.mode});
  final String? lang;
  final String? mode;

  @override
  List<Object?> get props => [lang ?? '', mode ?? ''];
}

class UploadAvatarEvent extends ProfileEvent {

  const UploadAvatarEvent({required this.filePath});
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

// ----- Cubit -----

class ProfileCubit extends Cubit<ProfileState> {

  ProfileCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updatePreferencesUseCase,
    required this.uploadAvatarUseCase,
  }) : super(const ProfileInitial());
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdatePreferencesUseCase updatePreferencesUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;

  Future<void> getProfile() async {
    emit(const ProfileLoading());
    final result = await getProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    emit(const ProfileLoading());
    final result = await updateProfileUseCase(
      firstName: firstName,
      lastName: lastName,
    );
    result.fold(
      (failure) => emit(ProfileError(_mapFailureToMessage(failure))),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> uploadAvatar(String filePath) async {
    final currentState = state;
    emit(const ProfileLoading());
    final result = await uploadAvatarUseCase(filePath);
    result.fold(
      (failure) {
        emit(ProfileError(_mapFailureToMessage(failure)));
        if (currentState case ProfileLoaded(:final profile)) {
          emit(ProfileLoaded(profile));
        }
      },
      (avatarUrl) {
        if (currentState case ProfileLoaded(:final profile)) {
          emit(ProfileLoaded(ProfileEntity(
            id: profile.id,
            email: profile.email,
            firstName: profile.firstName,
            lastName: profile.lastName,
            role: profile.role,
            avatarUrl: avatarUrl,
            lang: profile.lang,
            mode: profile.mode,
            createdAt: profile.createdAt,
          )));
        }
      },
    );
  }

  Future<void> updatePreferences({
    String? lang,
    String? mode,
  }) async {
    final currentState = state;
    if (currentState case ProfileLoaded(:final profile)) {
      // Optimistic update
      emit(ProfileLoaded(ProfileEntity(
        id: profile.id,
        email: profile.email,
        firstName: profile.firstName,
        lastName: profile.lastName,
        role: profile.role,
        avatarUrl: profile.avatarUrl,
        lang: lang ?? profile.lang,
        mode: mode ?? profile.mode,
        createdAt: profile.createdAt,
      )));
    }
    final result = await updatePreferencesUseCase(lang: lang, mode: mode);
    result.fold(
      (failure) {
        // Revert on failure — re-fetch profile
        getProfile();
      },
      (_) {
        // Success — UI already updated optimistically
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure f => f.message,
      AuthFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}
