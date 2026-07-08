class SubscriptionEntity {
  final String id;
  final String planType;
  final String status;
  final double storageUsed;
  final double storageLimit;
  final DateTime? startDate;
  final DateTime? endDate;

  const SubscriptionEntity({
    required this.id,
    required this.planType,
    required this.status,
    this.storageUsed = 0,
    this.storageLimit = 0,
    this.startDate,
    this.endDate,
  });

  bool get isActive => status == 'active';
  bool get isFree => planType == 'free';
  double get storageUsagePercent =>
      storageLimit > 0 ? (storageUsed / storageLimit) * 100 : 0;
}
