import 'package:lms/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    super.isRead,
    super.type,
    super.referenceId,
    super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      type: json['type'] as String?,
      referenceId: json['referenceId'] as String? ?? json['reference_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      type: type,
      referenceId: referenceId,
      createdAt: createdAt,
    );
  }
}
