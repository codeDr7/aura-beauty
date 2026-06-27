import '../../domain/entities/price_alert.dart';

class PriceAlertModel extends PriceAlert {
  const PriceAlertModel({
    required super.id,
    required super.productName,
    required super.brand,
    required super.currentPrice,
    required super.targetPrice,
    required super.originalPrice,
    super.isActive,
  });

  factory PriceAlertModel.fromJson(Map<String, dynamic> json) {
    return PriceAlertModel(
      id: json['id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      targetPrice: (json['target_price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_name': productName,
    'brand': brand,
    'current_price': currentPrice,
    'target_price': targetPrice,
    'original_price': originalPrice,
    'is_active': isActive,
  };
}
