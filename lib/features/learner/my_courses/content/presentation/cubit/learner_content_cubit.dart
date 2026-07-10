import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/my_courses/content/domain/usecases/get_my_content_detail_usecase.dart';
import 'package:lms/features/learner/my_courses/content/domain/usecases/get_my_course_contents_usecase.dart';
import 'package:lms/features/shared/domain/entities/content_entity.dart';

sealed class LearnerContentState extends Equatable {
  const LearnerContentState();

  @override
  List<Object?> get props => [];
}

class LearnerContentInitial extends LearnerContentState {
  const LearnerContentInitial();
}

class LearnerContentLoading extends LearnerContentState {
  const LearnerContentLoading();
}

class LearnerContentLoaded extends LearnerContentState {

  const LearnerContentLoaded({
    required this.contents,
    required this.courseId,
    required this.totalItems,
  });
  final List<ContentEntity> contents;
  final String courseId;
  final int totalItems;

  @override
  List<Object?> get props => [contents, courseId, totalItems];
}

class LearnerContentError extends LearnerContentState {

  const LearnerContentError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class LearnerContentDetailLoaded extends LearnerContentState {

  const LearnerContentDetailLoaded(this.content);
  final ContentEntity content;

  @override
  List<Object?> get props => [content];
}

class LearnerContentDetailError extends LearnerContentState {

  const LearnerContentDetailError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class LearnerContentCubit extends Cubit<LearnerContentState> {


  LearnerContentCubit({
    required this.getMyCourseContentsUseCase,
    required this.getMyContentDetailUseCase,
  }) : super(const LearnerContentInitial());
  final GetMyCourseContentsUseCase getMyCourseContentsUseCase;
  final GetMyContentDetailUseCase getMyContentDetailUseCase;
  Future<void> getContents(String courseId, {int page = 1, int limit = 10}) async {
    emit(const LearnerContentLoading());
    final result = await getMyCourseContentsUseCase(
      courseId,
      page: page,
      limit: limit,
    );
    result.fold(
      (failure) => emit(LearnerContentError(_mapFailureToMessage(failure))),
      (paginated) => emit(LearnerContentLoaded(
        contents: paginated.data,
        courseId: courseId,
        totalItems: paginated.totalItems,
      )),
    );
  }

  Future<void> getContentDetail(String courseId, String contentId) async {
    emit(const LearnerContentLoading());
    final result = await getMyContentDetailUseCase(courseId, contentId);
    result.fold(
      (failure) => emit(LearnerContentDetailError(_mapFailureToMessage(failure))),
      (content) => emit(LearnerContentDetailLoaded(content)),
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
