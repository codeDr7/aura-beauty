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
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      price: json['price'] as String? ?? '\$0.00',
      priceValue: (json['price_value'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      badgeLabel: json['badge_label'] as String?,
      category: json['category'] as String?,
      rating: json['rating'] as int?,
      reviewCount: json['review_count'] as int?,
      keyIngredients: (json['key_ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isRecommended: json['is_recommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'subtitle': subtitle,
    'price': price,
    'price_value': priceValue,
    'image_url': imageUrl,
    'badge_label': badgeLabel,
    'category': category,
    'rating': rating,
    'review_count': reviewCount,
    'key_ingredients': keyIngredients,
    'is_recommended': isRecommended,
  };
}
