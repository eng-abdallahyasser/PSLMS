class SubscriptionPlanEntity {
  final String id;
  final String name;
  final String type;
  final double price;
  final String currency;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.currency = 'USD',
    this.features = const [],
    this.isPopular = false,
  });

  String get formattedPrice => price == 0 ? 'Free' : '\$${price.toStringAsFixed(0)}';
  String get pricePeriod => price == 0 ? '' : '/month';
}
