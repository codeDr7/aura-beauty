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
      id: json['name'] as String? ?? '',
      name: json['plan_name'] as String? ?? '',
      monthlyPrice: (json['price_monthly'] as num?)?.toDouble() ?? 0.0,
      annualPrice: (json['price_yearly'] as num?)?.toDouble() ?? 0.0,
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
    'plan_name': name,
    'price_monthly': monthlyPrice,
    'price_yearly': annualPrice,
    'features': features,
  };
}
