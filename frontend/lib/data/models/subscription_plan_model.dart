import '../../domain/entities/subscription_plan.dart';

class SubscriptionPlanModel extends SubscriptionPlan {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.monthlyPrice,
    required super.annualPrice,
    required super.description,
    required super.features,
    super.isRecommended,
    super.isCurrent,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      monthlyPrice: (json['monthly_price'] as num?)?.toDouble() ?? 0.0,
      annualPrice: (json['annual_price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isRecommended: json['is_recommended'] as bool? ?? false,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'monthly_price': monthlyPrice,
    'annual_price': annualPrice,
    'description': description,
    'features': features,
    'is_recommended': isRecommended,
    'is_current': isCurrent,
  };
}
