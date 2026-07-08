import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_plan_entity.dart';

class SubscriptionPlanModel {
  final String id;
  final String name;
  final String type;
  final double price;
  final String currency;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.currency = 'USD',
    this.features = const [],
    this.isPopular = false,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? json['planType'] as String? ?? 'free',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'price': price,
        'currency': currency,
        'features': features,
        'isPopular': isPopular,
      };

  SubscriptionPlanEntity toEntity() => SubscriptionPlanEntity(
        id: id,
        name: name,
        type: type,
        price: price,
        currency: currency,
        features: features,
        isPopular: isPopular,
      );
}
