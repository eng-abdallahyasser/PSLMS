import 'package:lms/features/instructor/subscriptions/domain/entities/storage_addon_entity.dart';

class StorageAddonModel {

  const StorageAddonModel({
    required this.id,
    required this.sizeGb,
    required this.purchasedDate,
    required this.price,
  });

  factory StorageAddonModel.fromJson(Map<String, dynamic> json) {
    return StorageAddonModel(
      id: json['id'] as String? ?? '',
      sizeGb: json['sizeGb'] as int? ?? json['size'] as int? ?? 0,
      purchasedDate: json['purchasedDate'] as String? ?? json['createdAt'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
  final String id;
  final int sizeGb;
  final String purchasedDate;
  final double price;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sizeGb': sizeGb,
        'purchasedDate': purchasedDate,
        'price': price,
      };

  StorageAddonEntity toEntity() => StorageAddonEntity(
        id: id,
        sizeGb: sizeGb,
        purchasedDate: DateTime.tryParse(purchasedDate) ?? DateTime.now(),
        price: price,
      );
}
