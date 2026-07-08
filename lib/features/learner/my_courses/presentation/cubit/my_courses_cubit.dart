import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/shared/domain/entities/my_course_detail_entity.dart';
import 'package:lms/features/learner/my_courses/domain/usecases/get_my_course_detail_usecase.dart';
import 'package:lms/features/learner/my_courses/domain/usecases/get_my_courses_usecase.dart';

sealed class MyCoursesState extends Equatable {
  const MyCoursesState();

  @override
  List<Object?> get props => [];
}

class MyCoursesInitial extends MyCoursesState {
  const MyCoursesInitial();
}

class MyCoursesLoading extends MyCoursesState {
  const MyCoursesLoading();
}

class MyCoursesLoaded extends MyCoursesState {
  final List<CourseEntity> courses;
  final bool hasReachedMax;

  const MyCoursesLoaded({
    required this.courses,
    this.hasReachedMax = false,
  });

  MyCoursesLoaded copyWith({
    List<CourseEntity>? courses,
    bool? hasReachedMax,
  }) {
    return MyCoursesLoaded(
      courses: courses ?? this.courses,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [courses, hasReachedMax];
}

class MyCoursesError extends MyCoursesState {
  final String message;

  const MyCoursesError(this.message);

  @override
  List<Object?> get props => [message];
}

class MyCourseDetailLoading extends MyCoursesState {
  const MyCourseDetailLoading();
}

class MyCourseDetailLoaded extends MyCoursesState {
  final MyCourseDetailEntity detail;

  const MyCourseDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

class MyCourseDetailError extends MyCoursesState {
  final String message;

  const MyCourseDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class MyCoursesCubit extends Cubit<MyCoursesState> {
  final GetMyCoursesUseCase getMyCoursesUseCase;
  final GetMyCourseDetailUseCase getMyCourseDetailUseCase;

  int _currentPage = 1;
  static const int _pageSize = 10;

  MyCoursesCubit({
    required this.getMyCoursesUseCase,
    required this.getMyCourseDetailUseCase,
  }) : super(const MyCoursesInitial());

  Future<void> getMyCourses({int page = 1}) async {
    if (page == 1) {
      emit(const MyCoursesLoading());
    }
    _currentPage = page;
    final result = await getMyCoursesUseCase(page: page, limit: _pageSize);
    result.fold(
      (failure) => emit(MyCoursesError(_mapFailureToMessage(failure))),
      (courses) {
        final currentState = state;
        if (currentState is MyCoursesLoaded && page > 1) {
          emit(MyCoursesLoaded(
            courses: [...currentState.courses, ...courses],
            hasReachedMax: courses.length < _pageSize,
          ));
        } else {
          emit(MyCoursesLoaded(
            courses: courses,
            hasReachedMax: courses.length < _pageSize,
          ));
        }
      },
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is MyCoursesLoaded && !currentState.hasReachedMax) {
      await getMyCourses(page: _currentPage + 1);
    }
  }

  Future<void> getMyCourseDetail(String courseId) async {
    emit(const MyCourseDetailLoading());
    final result = await getMyCourseDetailUseCase(courseId);
    result.fold(
      (failure) => emit(MyCourseDetailError(_mapFailureToMessage(failure))),
      (detail) => emit(MyCourseDetailLoaded(detail)),
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
