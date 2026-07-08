class StorageAddonEntity {
  final String id;
  final int sizeGb;
  final DateTime purchasedDate;
  final double price;

  const StorageAddonEntity({
    required this.id,
    required this.sizeGb,
    required this.purchasedDate,
    required this.price,
  });

  String get formattedSize => '$sizeGb GB';
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}
