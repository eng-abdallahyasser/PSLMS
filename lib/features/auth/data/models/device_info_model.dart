class DeviceInfo {
  final String brand;
  final String deviceType;
  final String? osVersion;

  const DeviceInfo({
    required this.brand,
    required this.deviceType,
    this.osVersion,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      brand: json['brand'] as String,
      deviceType: json['deviceType'] as String,
      osVersion: json['osVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'deviceType': deviceType,
      if (osVersion != null) 'osVersion': osVersion,
    };
  }
}
