import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/profile/domain/entities/profile_entity.dart';

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
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

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
  final String? name;
  final String? bio;

  const UpdateProfileEvent({this.name, this.bio});

  @override
  List<Object?> get props => [name ?? '', bio ?? ''];
}

// ----- Cubit -----

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileInitial());

  Future<void> getProfile() async {
    emit(const ProfileLoading());
    // TODO: Implement with real data source
    await Future.delayed(const Duration(milliseconds: 300));
    emit(const ProfileLoaded(ProfileEntity(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      bio: 'Lifelong learner',
      joinedAt: null,
    )));
  }

  Future<void> updateProfile({String? name, String? bio}) async {
    emit(const ProfileLoading());
    // TODO: Implement with real data source
    await Future.delayed(const Duration(milliseconds: 300));
    emit(ProfileLoaded(ProfileEntity(
      id: '1',
      name: name ?? 'John Doe',
      email: 'john@example.com',
      bio: bio,
      joinedAt: null,
    )));
  }
}
