import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String? subtitle;
  final String price;
  final double priceValue;
  final String? imageUrl;
  final String? badgeLabel;
  final String? category;
  final int? rating;
  final int? reviewCount;
  final List<String>? keyIngredients;
  final bool isRecommended;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    this.subtitle,
    this.price = '\$0.00',
    this.priceValue = 0.0,
    this.imageUrl,
    this.badgeLabel,
    this.category,
    this.rating,
    this.reviewCount,
    this.keyIngredients,
    this.isRecommended = false,
  });

  @override
  List<Object?> get props => [
    id, name, brand, subtitle, price, priceValue, imageUrl,
    badgeLabel, category, rating, reviewCount, keyIngredients, isRecommended,
  ];
}
