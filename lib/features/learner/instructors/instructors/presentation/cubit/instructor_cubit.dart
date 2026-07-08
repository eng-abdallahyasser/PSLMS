import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/courses/domain/entities/course_entity.dart';
import 'package:lms/features/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/instructors/domain/entities/invitation_info_entity.dart';
import 'package:lms/features/instructors/domain/usecases/accept_invitation_usecase.dart';
import 'package:lms/features/instructors/domain/usecases/get_instructor_courses_usecase.dart';
import 'package:lms/features/instructors/domain/usecases/get_instructor_profile_usecase.dart';
import 'package:lms/features/instructors/domain/usecases/get_invitation_info_usecase.dart';
import 'package:lms/features/instructors/domain/usecases/get_my_instructors_usecase.dart';
import 'package:lms/features/instructors/domain/usecases/request_to_join_usecase.dart';
import 'package:lms/features/instructors/domain/usecases/search_instructors_usecase.dart';

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
  final List<InstructorProfileEntity> instructors;

  const InstructorsSearchLoaded(this.instructors);

  @override
  List<Object?> get props => [instructors];
}

class InstructorsSearchError extends InstructorState {
  final String message;

  const InstructorsSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class InstructorProfileLoading extends InstructorState {
  const InstructorProfileLoading();
}

class InstructorProfileLoaded extends InstructorState {
  final InstructorProfileEntity instructor;

  const InstructorProfileLoaded(this.instructor);

  @override
  List<Object?> get props => [instructor];
}

class InstructorProfileError extends InstructorState {
  final String message;

  const InstructorProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class InstructorActionSuccess extends InstructorState {
  final String message;

  const InstructorActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class InstructorActionError extends InstructorState {
  final String message;

  const InstructorActionError(this.message);

  @override
  List<Object?> get props => [message];
}

class MyInstructorsLoading extends InstructorState {
  const MyInstructorsLoading();
}

class MyInstructorsLoaded extends InstructorState {
  final List<InstructorProfileEntity> instructors;

  const MyInstructorsLoaded(this.instructors);

  @override
  List<Object?> get props => [instructors];
}

class MyInstructorsError extends InstructorState {
  final String message;

  const MyInstructorsError(this.message);

  @override
  List<Object?> get props => [message];
}

class InstructorCoursesLoading extends InstructorState {
  const InstructorCoursesLoading();
}

class InstructorCoursesLoaded extends InstructorState {
  final List<CourseEntity> courses;

  const InstructorCoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class InstructorCoursesError extends InstructorState {
  final String message;

  const InstructorCoursesError(this.message);

  @override
  List<Object?> get props => [message];
}

class InvitationInfoLoading extends InstructorState {
  const InvitationInfoLoading();
}

class InvitationInfoLoaded extends InstructorState {
  final InvitationInfoEntity info;

  const InvitationInfoLoaded(this.info);

  @override
  List<Object?> get props => [info];
}

class InvitationInfoError extends InstructorState {
  final String message;

  const InvitationInfoError(this.message);

  @override
  List<Object?> get props => [message];
}

class InstructorCubit extends Cubit<InstructorState> {
  final SearchInstructorsUseCase searchInstructorsUseCase;
  final GetInstructorProfileUseCase getInstructorProfileUseCase;
  final RequestToJoinUseCase requestToJoinUseCase;
  final GetMyInstructorsUseCase getMyInstructorsUseCase;
  final GetInstructorCoursesUseCase getInstructorCoursesUseCase;
  final GetInvitationInfoUseCase getInvitationInfoUseCase;
  final AcceptInvitationUseCase acceptInvitationUseCase;

  InstructorCubit({
    required this.searchInstructorsUseCase,
    required this.getInstructorProfileUseCase,
    required this.requestToJoinUseCase,
    required this.getMyInstructorsUseCase,
    required this.getInstructorCoursesUseCase,
    required this.getInvitationInfoUseCase,
    required this.acceptInvitationUseCase,
  }) : super(const InstructorInitial());

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
    emit(const InstructorProfileLoading());
    final result = await requestToJoinUseCase(instructorId);
    result.fold(
      (failure) => emit(InstructorActionError(_mapFailureToMessage(failure))),
      (_) => emit(const InstructorActionSuccess('Join request sent!')),
    );
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
