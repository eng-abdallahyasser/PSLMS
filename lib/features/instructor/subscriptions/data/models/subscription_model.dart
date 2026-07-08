import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_entity.dart';

class SubscriptionModel {
  final String id;
  final String planType;
  final String status;
  final double storageUsed;
  final double storageLimit;
  final String? startDate;
  final String? endDate;

  const SubscriptionModel({
    required this.id,
    required this.planType,
    required this.status,
    this.storageUsed = 0,
    this.storageLimit = 0,
    this.startDate,
    this.endDate,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String? ?? '',
      planType: json['planType'] as String? ?? 'free',
      status: json['status'] as String? ?? 'active',
      storageUsed: (json['storageUsed'] as num?)?.toDouble() ?? 0,
      storageLimit: (json['storageLimit'] as num?)?.toDouble() ?? 0,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'planType': planType,
        'status': status,
        'storageUsed': storageUsed,
        'storageLimit': storageLimit,
        'startDate': startDate,
        'endDate': endDate,
      };

  SubscriptionEntity toEntity() => SubscriptionEntity(
        id: id,
        planType: planType,
        status: status,
        storageUsed: storageUsed,
        storageLimit: storageLimit,
        startDate: startDate != null ? DateTime.tryParse(startDate!) : null,
        endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
      );
}
