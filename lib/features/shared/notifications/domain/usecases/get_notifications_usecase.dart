import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:lms/features/shared/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {

  GetNotificationsUseCase(this.repository);
  final NotificationRepository repository;

  Future<Either<Failure, List<NotificationEntity>>> call() {
    return repository.getNotifications();
  }
}
