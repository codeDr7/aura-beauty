import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.brand,
    super.subtitle,
    super.price,
    super.priceValue,
    super.imageUrl,
    super.badgeLabel,
    super.category,
    super.rating,
    super.reviewCount,
    super.keyIngredients,
    super.isRecommended,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final priceNum = (json['price'] as num?)?.toDouble() ?? 0.0;
    return ProductModel(
      id: json['name'] as String? ?? '',
      name: json['product_name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      subtitle: json['description'] as String?,
      price: priceNum > 0 ? '\$${priceNum.toStringAsFixed(2)}' : '\$0.00',
      priceValue: priceNum,
      imageUrl: json['image_url'] as String?,
      badgeLabel: json['badge_label'] as String?,
      category: json['category'] as String?,
      rating: (json['product_score'] as num?)?.toInt(),
      reviewCount: json['review_count'] as int?,
      keyIngredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isRecommended: json['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_name': name,
    'brand': brand,
    'price': priceValue,
    'category': category,
    'ingredients': keyIngredients,
  };
}
