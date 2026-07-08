import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/auth/domain/entities/user_entity.dart';
import 'package:lms/features/shared/domain/entities/course_entity.dart';
import 'package:lms/features/instructor/courses/domain/usecases/create_course_usecase.dart';
import 'package:lms/features/instructor/courses/domain/usecases/delete_course_usecase.dart';
import 'package:lms/features/instructor/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms/features/instructor/courses/domain/usecases/update_course_usecase.dart';

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
  final int limit;
  final String? search;
  final String? visibilityFilter;

  const GetCoursesEvent({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.visibilityFilter,
  });

  @override
  List<Object?> get props => [page, limit, search ?? '', visibilityFilter ?? ''];
}

class LoadMoreCoursesEvent extends CourseEvent {
  const LoadMoreCoursesEvent();
}

class CreateCourseEvent extends CourseEvent {
  final String title;
  final String description;
  final String visibility;
  final String? thumbnailUrl;

  const CreateCourseEvent({
    required this.title,
    required this.description,
    this.visibility = 'PUBLIC',
    this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [title, description, visibility, thumbnailUrl ?? ''];
}

class UpdateCourseEvent extends CourseEvent {
  final String id;
  final String? title;
  final String? description;
  final String? visibility;
  final String? thumbnailUrl;

  const UpdateCourseEvent({
    required this.id,
    this.title,
    this.description,
    this.visibility,
    this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [id, title ?? '', description ?? '', visibility ?? '', thumbnailUrl ?? ''];
}

class DeleteCourseEvent extends CourseEvent {
  final String id;

  const DeleteCourseEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// ----- Cubit -----

class CourseCubit extends Cubit<CourseState> {
  final GetCoursesUseCase getCoursesUseCase;
  final CreateCourseUseCase createCourseUseCase;
  final UpdateCourseUseCase updateCourseUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;

  int _currentPage = 1;
  static const int _pageSize = 10;
  UserRole _currentRole = UserRole.learner;

  CourseCubit({
    required this.getCoursesUseCase,
    required this.createCourseUseCase,
    required this.updateCourseUseCase,
    required this.deleteCourseUseCase,
  }) : super(const CourseInitial());

  void setRole(UserRole role) {
    _currentRole = role;
  }

  Future<void> getCourses({
    UserRole? role,
    int page = 1,
    String? search,
    String? visibilityFilter,
  }) async {
    if (page == 1) {
      emit(const CourseLoading());
    }
    _currentPage = page;
    if (role != null) _currentRole = role;
    final result = await getCoursesUseCase(
      role: _currentRole,
      page: page,
      limit: _pageSize,
      search: search,
      visibilityFilter: visibilityFilter,
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

  Future<void> createCourse({
    required String title,
    required String description,
    String visibility = 'PUBLIC',
    String? thumbnailUrl,
  }) async {
    emit(const CourseLoading());
    final result = await createCourseUseCase(
      title: title,
      description: description,
      visibility: visibility,
      thumbnailUrl: thumbnailUrl,
    );
    result.fold(
      (failure) => emit(CourseError(_mapFailureToMessage(failure))),
      (_) => getCourses(),
    );
  }

  Future<void> updateCourse({
    required String id,
    String? title,
    String? description,
    String? visibility,
    String? thumbnailUrl,
  }) async {
    emit(const CourseLoading());
    final result = await updateCourseUseCase(
      id: id,
      title: title,
      description: description,
      visibility: visibility,
      thumbnailUrl: thumbnailUrl,
    );
    result.fold(
      (failure) => emit(CourseError(_mapFailureToMessage(failure))),
      (_) => getCourses(),
    );
  }

  Future<void> deleteCourse(String id) async {
    emit(const CourseLoading());
    final result = await deleteCourseUseCase(id);
    result.fold(
      (failure) => emit(CourseError(_mapFailureToMessage(failure))),
      (_) => getCourses(),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}
