import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    this.isRead = false,
    this.type,
    this.referenceId,
    this.createdAt,
  });
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String? type;
  final String? referenceId;
  final DateTime? createdAt;

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      type: type,
      referenceId: referenceId,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        isRead,
        type,
        referenceId,
        createdAt,
      ];
}
