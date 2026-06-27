import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final double monthlyPrice;
  final double annualPrice;
  final String description;
  final List<String> features;
  final bool isRecommended;
  final bool isCurrent;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.description,
    required this.features,
    this.isRecommended = false,
    this.isCurrent = false,
  });

  String get monthlyLabel => '\$${monthlyPrice.toStringAsFixed(monthlyPrice == 0 ? 0 : 2)}/mo';
  String get annualLabel => '\$${annualPrice.toStringAsFixed(annualPrice == 0 ? 0 : 2)}/yr';

  @override
  List<Object?> get props => [id, name, monthlyPrice, annualPrice, description, features, isRecommended, isCurrent];
}
