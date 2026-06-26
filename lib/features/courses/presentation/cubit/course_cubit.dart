import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/courses/domain/entities/course_entity.dart';
import 'package:lms/features/courses/domain/usecases/get_courses_usecase.dart';

// ----- States -----

sealed class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {
  const CourseInitial();
}

class CourseLoading extends CourseState {
  const CourseLoading();
}

class CourseLoaded extends CourseState {
  final List<CourseEntity> courses;
  final bool hasReachedMax;

  const CourseLoaded({
    required this.courses,
    this.hasReachedMax = false,
  });

  CourseLoaded copyWith({
    List<CourseEntity>? courses,
    bool? hasReachedMax,
  }) {
    return CourseLoaded(
      courses: courses ?? this.courses,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [courses, hasReachedMax];
}

class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}

// ----- Events -----

sealed class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class GetCoursesEvent extends CourseEvent {
  final int page;
  final int pageSize;

  const GetCoursesEvent({this.page = 1, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];
}

class LoadMoreCoursesEvent extends CourseEvent {
  const LoadMoreCoursesEvent();
}

// ----- Cubit -----

class CourseCubit extends Cubit<CourseState> {
  final GetCoursesUseCase getCoursesUseCase;
  int _currentPage = 1;
  static const int _pageSize = 20;

  CourseCubit({required this.getCoursesUseCase}) : super(const CourseInitial());

  Future<void> getCourses({int page = 1}) async {
    if (page == 1) {
      emit(const CourseLoading());
    }
    _currentPage = page;
    final result = await getCoursesUseCase(
      page: page,
      pageSize: _pageSize,
    );
    result.fold(
      (failure) => emit(CourseError(_mapFailureToMessage(failure))),
      (courses) {
        final currentState = state;
        if (currentState is CourseLoaded && page > 1) {
          emit(CourseLoaded(
            courses: [...currentState.courses, ...courses],
            hasReachedMax: courses.length < _pageSize,
          ));
        } else {
          emit(CourseLoaded(
            courses: courses,
            hasReachedMax: courses.length < _pageSize,
          ));
        }
      },
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is CourseLoaded && !currentState.hasReachedMax) {
      await getCourses(page: _currentPage + 1);
    }
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}
