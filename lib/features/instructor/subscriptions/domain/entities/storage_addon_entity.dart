class StorageAddonEntity {

  const StorageAddonEntity({
    required this.id,
    required this.sizeGb,
    required this.purchasedDate,
    required this.price,
  });
  final String id;
  final int sizeGb;
  final DateTime purchasedDate;
  final double price;

  String get formattedSize => '$sizeGb GB';
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}
