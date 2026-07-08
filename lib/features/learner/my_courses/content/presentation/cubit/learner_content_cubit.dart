import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/contents/domain/entities/content_entity.dart';
import 'package:lms/features/contents/domain/usecases/get_my_content_detail_usecase.dart';
import 'package:lms/features/contents/domain/usecases/get_my_course_contents_usecase.dart';

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
  final List<ContentEntity> contents;
  final String courseId;
  final int totalItems;

  const LearnerContentLoaded({
    required this.contents,
    required this.courseId,
    required this.totalItems,
  });

  @override
  List<Object?> get props => [contents, courseId, totalItems];
}

class LearnerContentError extends LearnerContentState {
  final String message;

  const LearnerContentError(this.message);

  @override
  List<Object?> get props => [message];
}

class LearnerContentDetailLoaded extends LearnerContentState {
  final ContentEntity content;

  const LearnerContentDetailLoaded(this.content);

  @override
  List<Object?> get props => [content];
}

class LearnerContentDetailError extends LearnerContentState {
  final String message;

  const LearnerContentDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class LearnerContentCubit extends Cubit<LearnerContentState> {
  final GetMyCourseContentsUseCase getMyCourseContentsUseCase;
  final GetMyContentDetailUseCase getMyContentDetailUseCase;

  LearnerContentCubit({
    required this.getMyCourseContentsUseCase,
    required this.getMyContentDetailUseCase,
  }) : super(const LearnerContentInitial());

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
