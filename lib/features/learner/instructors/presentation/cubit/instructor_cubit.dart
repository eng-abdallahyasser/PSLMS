import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/learner/instructors/domain/entities/invitation_info_entity.dart';
import 'package:lms/features/learner/instructors/domain/usecases/accept_invitation_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_instructor_courses_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_instructor_profile_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_invitation_info_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_my_instructors_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/request_to_join_usecase.dart';
import 'package:lms/features/learner/instructors/domain/usecases/search_instructors_usecase.dart';

sealed class InstructorState extends Equatable {
  const InstructorState();

  @override
  List<Object?> get props => [];
}

class InstructorInitial extends InstructorState {
  const InstructorInitial();
}

class InstructorsSearchLoading extends InstructorState {
  const InstructorsSearchLoading();
}

class InstructorsSearchLoaded extends InstructorState {

  const InstructorsSearchLoaded(this.instructors);
  final List<InstructorProfileEntity> instructors;

  @override
  List<Object?> get props => [instructors];
}

class InstructorsSearchError extends InstructorState {

  const InstructorsSearchError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class InstructorProfileLoading extends InstructorState {
  const InstructorProfileLoading();
}

class InstructorProfileLoaded extends InstructorState {

  const InstructorProfileLoaded(this.instructor, {this.isJoinRequestInProgress = false, this.joinMessage});
  final InstructorProfileEntity instructor;
  final bool isJoinRequestInProgress;
  final String? joinMessage;

  @override
  List<Object?> get props => [instructor, isJoinRequestInProgress, joinMessage];
}

class InstructorProfileError extends InstructorState {

  const InstructorProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class InstructorActionSuccess extends InstructorState {

  const InstructorActionSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class InstructorActionError extends InstructorState {

  const InstructorActionError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class MyInstructorsLoading extends InstructorState {
  const MyInstructorsLoading();
}

class MyInstructorsLoaded extends InstructorState {

  const MyInstructorsLoaded(this.instructors);
  final List<InstructorProfileEntity> instructors;

  @override
  List<Object?> get props => [instructors];
}

class MyInstructorsError extends InstructorState {

  const MyInstructorsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class InstructorCoursesLoading extends InstructorState {
  const InstructorCoursesLoading();
}

class InstructorCoursesLoaded extends InstructorState {

  const InstructorCoursesLoaded(this.courses);
  final List<CourseEntity> courses;

  @override
  List<Object?> get props => [courses];
}

class InstructorCoursesError extends InstructorState {

  const InstructorCoursesError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class InvitationInfoLoading extends InstructorState {
  const InvitationInfoLoading();
}

class InvitationInfoLoaded extends InstructorState {

  const InvitationInfoLoaded(this.info);
  final InvitationInfoEntity info;

  @override
  List<Object?> get props => [info];
}

class InvitationInfoError extends InstructorState {

  const InvitationInfoError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class InstructorCubit extends Cubit<InstructorState> {

  InstructorCubit({
    required this.searchInstructorsUseCase,
    required this.getInstructorProfileUseCase,
    required this.requestToJoinUseCase,
    required this.getMyInstructorsUseCase,
    required this.getInstructorCoursesUseCase,
    required this.getInvitationInfoUseCase,
    required this.acceptInvitationUseCase,
  }) : super(const InstructorInitial());
  final SearchInstructorsUseCase searchInstructorsUseCase;
  final GetInstructorProfileUseCase getInstructorProfileUseCase;
  final RequestToJoinUseCase requestToJoinUseCase;
  final GetMyInstructorsUseCase getMyInstructorsUseCase;
  final GetInstructorCoursesUseCase getInstructorCoursesUseCase;
  final GetInvitationInfoUseCase getInvitationInfoUseCase;
  final AcceptInvitationUseCase acceptInvitationUseCase;

  Future<void> searchInstructors({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    emit(const InstructorsSearchLoading());
    final result = await searchInstructorsUseCase(
      query: query,
      page: page,
      limit: limit,
    );
    result.fold(
      (failure) => emit(InstructorsSearchError(_mapFailureToMessage(failure))),
      (instructors) => emit(InstructorsSearchLoaded(instructors)),
    );
  }

  Future<void> getInstructorProfile(String id) async {
    emit(const InstructorProfileLoading());
    final result = await getInstructorProfileUseCase(id);
    result.fold(
      (failure) => emit(InstructorProfileError(_mapFailureToMessage(failure))),
      (instructor) => emit(InstructorProfileLoaded(instructor)),
    );
  }

  Future<void> requestToJoin(String instructorId) async {
    final currentProfile = state is InstructorProfileLoaded
        ? (state as InstructorProfileLoaded).instructor
        : null;
    if (currentProfile != null) {
      emit(InstructorProfileLoaded(currentProfile, isJoinRequestInProgress: true));
    }
    final result = await requestToJoinUseCase(instructorId);
    if (currentProfile != null) {
      result.fold(
        (failure) {
          emit(InstructorProfileLoaded(currentProfile, joinMessage: _mapFailureToMessage(failure)));
          emit(InstructorProfileLoaded(currentProfile));
        },
        (_) {
          emit(InstructorProfileLoaded(currentProfile, joinMessage: 'Join request sent!'));
          emit(InstructorProfileLoaded(currentProfile));
        },
      );
    }
  }

  Future<void> getMyInstructors() async {
    emit(const MyInstructorsLoading());
    final result = await getMyInstructorsUseCase();
    result.fold(
      (failure) => emit(MyInstructorsError(_mapFailureToMessage(failure))),
      (instructors) => emit(MyInstructorsLoaded(instructors)),
    );
  }

  Future<void> getInstructorCourses(String instructorId) async {
    emit(const InstructorCoursesLoading());
    final result = await getInstructorCoursesUseCase(instructorId);
    result.fold(
      (failure) => emit(InstructorCoursesError(_mapFailureToMessage(failure))),
      (courses) => emit(InstructorCoursesLoaded(courses)),
    );
  }

  Future<void> getInvitationInfo(String token) async {
    emit(const InvitationInfoLoading());
    final result = await getInvitationInfoUseCase(token);
    result.fold(
      (failure) => emit(InvitationInfoError(_mapFailureToMessage(failure))),
      (info) => emit(InvitationInfoLoaded(info)),
    );
  }

  Future<void> acceptInvitation(String token) async {
    emit(const InvitationInfoLoading());
    final result = await acceptInvitationUseCase(token);
    result.fold(
      (failure) => emit(InvitationInfoError(_mapFailureToMessage(failure))),
      (_) => emit(const InstructorActionSuccess('Invitation accepted!')),
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
