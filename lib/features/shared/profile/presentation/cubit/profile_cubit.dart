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

  const ProfileLoaded(
    this.profile, {
    this.saving = false,
    this.notice,
    this.noticeIsError = false,
  });
  final ProfileEntity profile;

  /// True while an action (edit/preferences/avatar) is in flight — the page
  /// stays interactive and shows small inline indicators instead of a
  /// full-screen spinner.
  final bool saving;

  /// One-shot success/error message for the last action.
  final String? notice;
  final bool noticeIsError;

  @override
  List<Object?> get props => [profile, saving, notice ?? '', noticeIsError];
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

  const UpdateProfileEvent({
    this.firstName,
    this.lastName,
    this.mobileNumber,
    this.universityId,
    this.faculty,
    this.department,
    this.year,
  });
  final String? firstName;
  final String? lastName;
  final String? mobileNumber;
  final String? universityId;
  final String? faculty;
  final String? department;
  final String? year;

  @override
  List<Object?> get props => [
        firstName ?? '',
        lastName ?? '',
        mobileNumber ?? '',
        universityId ?? '',
        faculty ?? '',
        department ?? '',
        year ?? '',
      ];
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

  Future<void> getProfile() => _fetch(showBlockingSpinner: true);

  /// Re-fetch keeping current content visible (pull-to-refresh).
  Future<void> refresh() => _fetch(showBlockingSpinner: false);

  Future<void> _fetch({required bool showBlockingSpinner}) async {
    if (showBlockingSpinner) emit(const ProfileLoading());
    final result = await getProfileUseCase();
    result.fold(
      (failure) {
        final message = _mapFailureToMessage(failure);
        final current = state;
        if (current case ProfileLoaded(:final profile)) {
          emit(ProfileLoaded(profile, notice: message, noticeIsError: true));
        } else {
          emit(ProfileError(message));
        }
      },
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? mobileNumber,
    String? universityId,
    String? faculty,
    String? department,
    String? year,
  }) async {
    final previous = _currentOrNull();
    if (previous case ProfileLoaded(:final profile)) {
      // Optimistic — keep the dialog values visible while saving.
      emit(ProfileLoaded(
        profile.copyWith(
          firstName: firstName,
          lastName: lastName,
          mobileNumber: mobileNumber,
          universityId: universityId,
          faculty: faculty,
          department: department,
          year: year,
        ),
        saving: true,
      ));
    }
    final result = await updateProfileUseCase(
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      universityId: universityId,
      faculty: faculty,
      department: department,
      year: year,
    );
    await result.fold(
      (failure) async => _revert(previous, _mapFailureToMessage(failure)),
      (profile) async => emit(ProfileLoaded(profile, notice: 'Profile updated')),
    );
  }

  Future<void> uploadAvatar(String filePath) async {
    final previous = _currentOrNull();
    if (previous case ProfileLoaded(:final profile)) {
      emit(ProfileLoaded(profile, saving: true));
    }
    final result = await uploadAvatarUseCase(filePath);
    await result.fold(
      (failure) async => _revert(previous, _mapFailureToMessage(failure)),
      (avatarUrl) async {
        final current = _currentOrNull();
        if (current case ProfileLoaded(:final profile)) {
          emit(ProfileLoaded(
            profile.copyWith(avatarUrl: avatarUrl),
            notice: 'Profile photo updated',
          ));
        }
      },
    );
  }

  Future<void> updatePreferences({
    String? lang,
    String? mode,
  }) async {
    final previous = _currentOrNull();
    if (previous case ProfileLoaded(:final profile)) {
      // Optimistic update.
      emit(ProfileLoaded(
        profile.copyWith(lang: lang, mode: mode),
        saving: true,
      ));
    }
    final result = await updatePreferencesUseCase(lang: lang, mode: mode);
    await result.fold(
      (failure) async => _revert(previous, _mapFailureToMessage(failure)),
      (_) async {
        final current = _currentOrNull();
        if (current case ProfileLoaded(:final profile)) {
          emit(ProfileLoaded(profile, notice: 'Preferences saved'));
        }
      },
    );
  }

  ProfileLoaded? _currentOrNull() {
    final current = state;
    return current is ProfileLoaded ? current : null;
  }

  void _revert(ProfileLoaded? previous, String errorMessage) {
    if (previous != null) {
      emit(ProfileLoaded(
        previous.profile,
        notice: errorMessage,
        noticeIsError: true,
      ));
    } else {
      emit(ProfileError(errorMessage));
    }
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
