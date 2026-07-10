import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/instructor/students/domain/entities/student_entity.dart';
import 'package:lms/features/instructor/students/domain/usecases/invite_student_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/list_requests_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/list_students_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/remove_student_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/respond_to_request_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/assign_courses_usecase.dart';
import 'package:lms/features/instructor/students/domain/usecases/get_assignments_usecase.dart';

// ----- States -----

sealed class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentLoading extends StudentState {
  const StudentLoading();
}

class StudentsLoaded extends StudentState {
  const StudentsLoaded({
    required this.students,
    required this.requests,
    this.hasReachedMax = false,
  });
  final List<StudentEntity> students;
  final List<StudentEntity> requests;
  final bool hasReachedMax;

  @override
  List<Object?> get props => [students, requests, hasReachedMax];
}

class StudentActionSuccess extends StudentState {
  const StudentActionSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class StudentError extends StudentState {
  const StudentError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ----- Cubit -----

class StudentCubit extends Cubit<StudentState> {
  StudentCubit({
    required this.inviteStudentUseCase,
    required this.listStudentsUseCase,
    required this.listRequestsUseCase,
    required this.respondToRequestUseCase,
    required this.removeStudentUseCase,
    required this.assignCoursesUseCase,
    required this.getAssignmentsUseCase,
  }) : super(const StudentInitial());
  final InviteStudentUseCase inviteStudentUseCase;
  final ListStudentsUseCase listStudentsUseCase;
  final ListRequestsUseCase listRequestsUseCase;
  final RespondToRequestUseCase respondToRequestUseCase;
  final RemoveStudentUseCase removeStudentUseCase;
  final AssignCoursesUseCase assignCoursesUseCase;
  final GetAssignmentsUseCase getAssignmentsUseCase;

  int _currentPage = 1;
  static const int _pageSize = 10;

  Future<void> getStudents({int page = 1, String? status}) async {
    final current = state;
    List<StudentEntity> currentRequests = [];
    if (current is StudentsLoaded) {
      currentRequests = current.requests;
    }

    if (page == 1 && currentRequests.isEmpty) {
      emit(const StudentLoading());
    }
    _currentPage = page;
    final result = await listStudentsUseCase(
      ListStudentsParams(status: status, page: page, limit: _pageSize),
    );
    result.fold(
      (failure) => emit(StudentError(_mapFailure(failure))),
      (paginated) {
        final current = state;
        List<StudentEntity> requests = currentRequests;
        if (current is StudentsLoaded) {
          requests = current.requests;
        }

        if (current is StudentsLoaded && page > 1) {
          emit(StudentsLoaded(
            students: [...current.students, ...paginated.data],
            requests: requests,
            hasReachedMax: paginated.data.length < _pageSize,
          ));
        } else {
          emit(StudentsLoaded(
            students: paginated.data,
            requests: requests,
            hasReachedMax: paginated.data.length < _pageSize,
          ));
        }
      },
    );
  }

  Future<void> loadMoreStudents() async {
    final current = state;
    if (current is StudentsLoaded && !current.hasReachedMax) {
      await getStudents(page: _currentPage + 1);
    }
  }

  Future<void> getRequests({int page = 1}) async {
    final current = state;
    List<StudentEntity> currentStudents = [];
    bool currentHasReachedMax = false;
    if (current is StudentsLoaded) {
      currentStudents = current.students;
      currentHasReachedMax = current.hasReachedMax;
    }

    if (currentStudents.isEmpty) {
      emit(const StudentLoading());
    }
    final result = await listRequestsUseCase(
      ListRequestsParams(page: page, limit: _pageSize),
    );
    result.fold(
      (failure) => emit(StudentError(_mapFailure(failure))),
      (paginated) {
        final current = state;
        List<StudentEntity> students = currentStudents;
        bool hasReachedMax = currentHasReachedMax;
        if (current is StudentsLoaded) {
          students = current.students;
          hasReachedMax = current.hasReachedMax;
        }
        emit(StudentsLoaded(
          students: students,
          requests: paginated.data,
          hasReachedMax: hasReachedMax,
        ));
      },
    );
  }

  Future<void> inviteStudent(String email) async {
    emit(const StudentLoading());
    final result = await inviteStudentUseCase(
      InviteStudentParams(email: email),
    );
    result.fold(
      (failure) => emit(StudentError(_mapFailure(failure))),
      (_) {
        emit(const StudentActionSuccess('Invitation sent!'));
        getStudents();
      },
    );
  }

  Future<void> respondToRequest(String requestId, String action) async {
    emit(const StudentLoading());
    final result = await respondToRequestUseCase(
      RespondToRequestParams(requestId: requestId, action: action),
    );
    result.fold(
      (failure) => emit(StudentError(_mapFailure(failure))),
      (_) {
        emit(const StudentActionSuccess('Request responded'));
        getRequests();
      },
    );
  }

  Future<void> removeStudent(String studentId) async {
    emit(const StudentLoading());
    final result = await removeStudentUseCase(
      RemoveStudentParams(studentId: studentId),
    );
    result.fold(
      (failure) => emit(StudentError(_mapFailure(failure))),
      (_) {
        emit(const StudentActionSuccess('Student removed'));
        getStudents();
      },
    );
  }

  Future<void> assignCourses(String studentId, List<String> courseIds) async {
    emit(const StudentLoading());
    final result = await assignCoursesUseCase(
      AssignCoursesParams(studentId: studentId, courseIds: courseIds),
    );
    result.fold(
      (failure) => emit(StudentError(_mapFailure(failure))),
      (_) {
        emit(const StudentActionSuccess('Courses assigned!'));
        getStudents();
      },
    );
  }

  Future<List<String>> getAssignments(String studentId) async {
    final result = await getAssignmentsUseCase(studentId);
    return result.fold(
      (failure) => [],
      (courseIds) => courseIds,
    );
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure f => f.message,
      AuthFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}
