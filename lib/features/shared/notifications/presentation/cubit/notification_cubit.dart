import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:lms/features/shared/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:lms/features/shared/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:lms/features/shared/notifications/domain/usecases/mark_notification_read_usecase.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationsLoading extends NotificationState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationState {

  const NotificationsLoaded(this.notifications);
  final List<NotificationEntity> notifications;

  @override
  List<Object?> get props => [notifications];
}

class NotificationsError extends NotificationState {

  const NotificationsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class NotificationsActionSuccess extends NotificationState {

  const NotificationsActionSuccess(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class NotificationCubit extends Cubit<NotificationState> {

  NotificationCubit({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsReadUseCase,
  }) : super(const NotificationInitial());
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;

  Future<void> getNotifications() async {
    emit(const NotificationsLoading());
    final result = await getNotificationsUseCase();
    result.fold(
      (failure) => emit(NotificationsError(_mapFailureToMessage(failure))),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> markAsRead(String id) async {
    final result = await markNotificationReadUseCase(id);
    result.fold(
      (failure) => emit(NotificationsError(_mapFailureToMessage(failure))),
      (_) {
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          final updated = currentState.notifications.map((n) {
            return n.id == id ? n.copyWith(isRead: true) : n;
          }).toList();
          emit(NotificationsLoaded(updated));
        }
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await markAllNotificationsReadUseCase();
    result.fold(
      (failure) => emit(NotificationsError(_mapFailureToMessage(failure))),
      (_) {
        final currentState = state;
        if (currentState is NotificationsLoaded) {
          final updated = currentState.notifications
              .map((n) => n.copyWith(isRead: true))
              .toList();
          emit(NotificationsLoaded(updated));
        }
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
