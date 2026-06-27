import 'package:equatable/equatable.dart';

class PriceAlert extends Equatable {
  final String id;
  final String productName;
  final String brand;
  final double currentPrice;
  final double targetPrice;
  final double originalPrice;
  final bool isActive;

  const PriceAlert({
    required this.id,
    required this.productName,
    required this.brand,
    required this.currentPrice,
    required this.targetPrice,
    required this.originalPrice,
    this.isActive = true,
  });

  double get progress {
    final drop = originalPrice - currentPrice;
    final target = originalPrice - targetPrice;
    if (target <= 0) return 1.0;
    return (drop / target).clamp(0.0, 1.0);
  }

  double get savingsPercent {
    final saved = originalPrice - currentPrice;
    return ((saved / originalPrice) * 100);
  }

  @override
  List<Object?> get props => [id, productName, brand, currentPrice, targetPrice, originalPrice, isActive];
}
