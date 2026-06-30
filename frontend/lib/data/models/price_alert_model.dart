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
      id: json['name'] as String? ?? '',
      productName: json['product'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      targetPrice: (json['target_price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_triggered'] != true,
    );
  }

  Map<String, dynamic> toJson() => {
    'product': productName,
    'target_price': targetPrice,
  };
}
