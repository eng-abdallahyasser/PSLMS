import 'package:dartz/dartz.dart';
import 'package:lms/core/errors/failures.dart';
import 'package:lms/features/shared/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationReadUseCase {

  MarkNotificationReadUseCase(this.repository);
  final NotificationRepository repository;

  Future<Either<Failure, void>> call(String id) {
    return repository.markAsRead(id);
  }
}
