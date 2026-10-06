class StorageUsage {
  const StorageUsage({
    required this.quotaBytes,
    required this.usedBytes,
    this.activeSubscriptions = 0,
  });

  final int quotaBytes;
  final int usedBytes;
  final int activeSubscriptions;

  double get usedPercentage =>
      quotaBytes <= 0 ? 0 : (usedBytes / quotaBytes * 100).clamp(0, 100);

  factory StorageUsage.fromJson(Map<String, dynamic> json) {
    final quota = (json['effectiveQuotaBytes'] ??
            json['quotaBytes'] ??
            json['totalBytes'] ??
            json['quota'])
        as num?;
    final used =
        (json['usedBytes'] ?? json['used'] ?? json['usedStorageBytes'])
            as num?;
    final subs = json['activeSubscriptions'];
    return StorageUsage(
      quotaBytes: quota?.toInt() ?? 0,
      usedBytes: used?.toInt() ?? 0,
      activeSubscriptions: subs is List
          ? subs.length
          : (subs is num ? subs.toInt() : 0),
    );
  }
}

class StoragePlan {
  const StoragePlan({
    required this.id,
    required this.name,
    this.nameAr,
    required this.gigabytes,
    required this.price,
    this.currency = 'EGP',
    this.durationDays = 90,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? nameAr;
  final int gigabytes;
  final double price;
  final String currency;
  final int durationDays;
  final bool isActive;

  factory StoragePlan.fromJson(Map<String, dynamic> json) {
    return StoragePlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String?,
      gigabytes: (json['gigabytes'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 90,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class SubscribeResult {
  const SubscribeResult({required this.checkoutUrl});

  final String checkoutUrl;

  factory SubscribeResult.fromJson(Map<String, dynamic> json) {
    final session = json['session'];
    final nested = session is Map<String, dynamic> ? session : null;
    return SubscribeResult(
      checkoutUrl: json['checkoutUrl'] as String? ??
          json['url'] as String? ??
          nested?['checkoutUrl'] as String? ??
          '',
    );
  }
}

class RevenueSummary {
  const RevenueSummary({
    this.totalSales = 0,
    this.grossRevenue = 0,
    this.totalCommission = 0,
    this.netRevenue = 0,
    this.currency = 'EGP',
  });

  final int totalSales;
  final double grossRevenue;
  final double totalCommission;
  final double netRevenue;
  final String currency;

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    final sales = (json['totalSales'] ??
        json['salesCount'] ??
        json['totalOrders']) as num?;
    return RevenueSummary(
      totalSales: sales?.toInt() ?? 0,
      grossRevenue: ((json['grossRevenue'] ??
              json['totalRevenue'] ??
              json['gross']) as num?)
          ?.toDouble() ??
          0,
      totalCommission: ((json['totalCommission'] ??
              json['commission'] ??
              json['platformCommission']) as num?)
          ?.toDouble() ??
          0,
      netRevenue: ((json['netRevenue'] ??
              json['netEarnings'] ??
              json['net']) as num?)
          ?.toDouble() ??
          0,
      currency: json['currency'] as String? ?? 'EGP',
    );
  }
}
