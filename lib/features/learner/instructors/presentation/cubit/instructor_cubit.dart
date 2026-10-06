import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/learner/instructors/domain/usecases/get_instructor_profile_usecase.dart';
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
  const InstructorProfileLoaded(this.instructor);
  final InstructorProfileEntity instructor;

  @override
  List<Object?> get props => [instructor];
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

class InstructorCubit extends Cubit<InstructorState> {
  InstructorCubit({
    required this.searchInstructorsUseCase,
    required this.getInstructorProfileUseCase,
  }) : super(const InstructorInitial());

  final SearchInstructorsUseCase searchInstructorsUseCase;
  final GetInstructorProfileUseCase getInstructorProfileUseCase;

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
      (instructors) {
        final q = query.trim().toLowerCase();
        final filtered = q.isEmpty
            ? instructors
            : instructors
                .where((i) => i.fullName.toLowerCase().contains(q))
                .toList();
        emit(InstructorsSearchLoaded(filtered));
      },
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

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure f => f.message,
      AuthFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}
