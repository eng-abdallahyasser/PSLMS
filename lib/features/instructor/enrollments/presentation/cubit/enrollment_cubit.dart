import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/enrollment_entity.dart';
import 'package:lms/features/learner/enrollments/domain/usecases/enroll_in_course_usecase.dart';
import 'package:lms/features/instructor/enrollments/domain/usecases/get_enrollments_usecase.dart';
import 'package:lms/features/instructor/enrollments/domain/usecases/invite_learner_usecase.dart';
import 'package:lms/features/instructor/enrollments/domain/usecases/remove_enrollment_usecase.dart';
import 'package:lms/features/instructor/enrollments/domain/usecases/respond_to_enrollment_usecase.dart';

// ----- States -----

sealed class EnrollmentState extends Equatable {
  const EnrollmentState();

  @override
  List<Object?> get props => [];
}

class EnrollmentInitial extends EnrollmentState {
  const EnrollmentInitial();
}

class EnrollmentLoading extends EnrollmentState {
  const EnrollmentLoading();
}

class EnrollmentLoaded extends EnrollmentState {
  final List<EnrollmentEntity> enrollments;

  const EnrollmentLoaded(this.enrollments);

  @override
  List<Object?> get props => [enrollments];
}

class EnrollmentActionSuccess extends EnrollmentState {
  final String message;

  const EnrollmentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EnrollmentError extends EnrollmentState {
  final String message;

  const EnrollmentError(this.message);

  @override
  List<Object?> get props => [message];
}

// ----- Cubit -----

class EnrollmentCubit extends Cubit<EnrollmentState> {
  final EnrollInCourseUseCase enrollInCourseUseCase;
  final GetEnrollmentsUseCase getEnrollmentsUseCase;
  final RespondToEnrollmentUseCase respondToEnrollmentUseCase;
  final InviteLearnerUseCase inviteLearnerUseCase;
  final RemoveEnrollmentUseCase removeEnrollmentUseCase;

  EnrollmentCubit({
    required this.enrollInCourseUseCase,
    required this.getEnrollmentsUseCase,
    required this.respondToEnrollmentUseCase,
    required this.inviteLearnerUseCase,
    required this.removeEnrollmentUseCase,
  }) : super(const EnrollmentInitial());

  Future<void> getEnrollments(String courseId) async {
    emit(const EnrollmentLoading());
    final result = await getEnrollmentsUseCase(courseId);
    result.fold(
      (failure) => emit(EnrollmentError(_mapFailureToMessage(failure))),
      (enrollments) => emit(EnrollmentLoaded(enrollments)),
    );
  }

  Future<void> enroll(String courseId) async {
    emit(const EnrollmentLoading());
    final result = await enrollInCourseUseCase(courseId);
    result.fold(
      (failure) => emit(EnrollmentError(_mapFailureToMessage(failure))),
      (_) => emit(const EnrollmentActionSuccess('Successfully enrolled!')),
    );
  }

  Future<void> respondToEnrollment(String enrollmentId, String status) async {
    emit(const EnrollmentLoading());
    final result = await respondToEnrollmentUseCase(
      enrollmentId: enrollmentId,
      status: status,
    );
    result.fold(
      (failure) => emit(EnrollmentError(_mapFailureToMessage(failure))),
      (_) => emit(EnrollmentActionSuccess(
        status == 'APPROVED'
            ? 'Enrollment approved'
            : 'Enrollment rejected',
      )),
    );
  }

  Future<void> inviteLearner(String courseId, String email) async {
    emit(const EnrollmentLoading());
    final result = await inviteLearnerUseCase(
      courseId: courseId,
      email: email,
    );
    result.fold(
      (failure) => emit(EnrollmentError(_mapFailureToMessage(failure))),
      (_) => emit(const EnrollmentActionSuccess('Invitation sent!')),
    );
  }

  Future<void> removeEnrollment(String enrollmentId) async {
    emit(const EnrollmentLoading());
    final result = await removeEnrollmentUseCase(enrollmentId);
    result.fold(
      (failure) => emit(EnrollmentError(_mapFailureToMessage(failure))),
      (_) => emit(const EnrollmentActionSuccess('Enrollment removed')),
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
