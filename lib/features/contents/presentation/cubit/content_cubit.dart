import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/contents/domain/entities/content_entity.dart';
import 'package:lms/features/contents/domain/usecases/get_course_contents_usecase.dart';
import 'package:lms/features/contents/domain/usecases/upload_content_usecase.dart';

// ----- States -----

sealed class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object?> get props => [];
}

class ContentInitial extends ContentState {
  const ContentInitial();
}

class ContentLoading extends ContentState {
  const ContentLoading();
}

class ContentLoaded extends ContentState {
  final List<ContentEntity> contents;
  final String courseId;

  const ContentLoaded({required this.contents, required this.courseId});

  @override
  List<Object?> get props => [contents, courseId];
}

class ContentActionSuccess extends ContentState {
  final String message;

  const ContentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ContentError extends ContentState {
  final String message;

  const ContentError(this.message);

  @override
  List<Object?> get props => [message];
}

// ----- Cubit -----

class ContentCubit extends Cubit<ContentState> {
  final GetCourseContentsUseCase getCourseContentsUseCase;
  final UploadContentUseCase uploadContentUseCase;

  ContentCubit({
    required this.getCourseContentsUseCase,
    required this.uploadContentUseCase,
  }) : super(const ContentInitial());

  Future<void> getContents(String courseId) async {
    emit(const ContentLoading());
    final result = await getCourseContentsUseCase(courseId);
    result.fold(
      (failure) => emit(ContentError(_mapFailureToMessage(failure))),
      (contents) => emit(ContentLoaded(contents: contents, courseId: courseId)),
    );
  }

  Future<void> uploadContent({
    required String courseId,
    required String filePath,
    required String title,
    String? description,
  }) async {
    emit(const ContentLoading());
    final result = await uploadContentUseCase(
      courseId: courseId,
      filePath: filePath,
      title: title,
      description: description,
    );
    result.fold(
      (failure) => emit(ContentError(_mapFailureToMessage(failure))),
      (_) {
        emit(const ContentActionSuccess('Content uploaded successfully!'));
        getContents(courseId);
      },
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
