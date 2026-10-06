import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/learner/purchases/domain/usecases/purchase_course_usecase.dart';

sealed class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object?> get props => [];
}

class PurchaseInitial extends PurchaseState {
  const PurchaseInitial();
}

class PurchaseLoading extends PurchaseState {
  const PurchaseLoading();
}

class PurchaseEnrolled extends PurchaseState {
  const PurchaseEnrolled({this.message = 'Enrolled successfully!'});
  final String message;

  @override
  List<Object?> get props => [message];
}

class PurchaseCheckoutRequired extends PurchaseState {
  const PurchaseCheckoutRequired(this.checkoutUrl);
  final String checkoutUrl;

  @override
  List<Object?> get props => [checkoutUrl];
}

class PurchaseError extends PurchaseState {
  const PurchaseError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit({required this.purchaseCourseUseCase})
      : super(const PurchaseInitial());

  final PurchaseCourseUseCase purchaseCourseUseCase;

  Future<void> purchase(String courseId) async {
    emit(const PurchaseLoading());
    final result = await purchaseCourseUseCase(courseId);
    result.fold(
      (failure) => emit(PurchaseError(_mapFailureToMessage(failure))),
      (purchase) {
        if (purchase.needsCheckout) {
          emit(PurchaseCheckoutRequired(purchase.checkoutUrl!));
        } else if (purchase.status == 'already_enrolled') {
          emit(const PurchaseEnrolled(message: 'Already enrolled in this course'));
        } else {
          emit(const PurchaseEnrolled());
        }
      },
    );
  }

  void reset() => emit(const PurchaseInitial());

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.statusCode == 409
          ? 'Already enrolled in this course'
          : f.message,
      NetworkFailure f => f.message,
      AuthFailure f => f.message,
      _ => 'An unexpected error occurred',
    };
  }
}
