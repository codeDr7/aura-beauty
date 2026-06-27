import '../../domain/entities/ingredient_interaction.dart';

class IngredientInteractionModel extends IngredientInteraction {
  const IngredientInteractionModel({
    required super.ingredientA,
    required super.ingredientB,
    required super.severity,
    required super.description,
    required super.recommendation,
  });

  factory IngredientInteractionModel.fromJson(Map<String, dynamic> json) {
    return IngredientInteractionModel(
      ingredientA: json['ingredient_a'] as String? ?? '',
      ingredientB: json['ingredient_b'] as String? ?? '',
      severity: _parseSeverity(json['severity'] as String? ?? 'safe'),
      description: json['description'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
    );
  }

  static ConflictSeverity _parseSeverity(String s) {
    switch (s) {
      case 'low':
        return ConflictSeverity.low;
      case 'medium':
        return ConflictSeverity.medium;
      case 'high':
        return ConflictSeverity.high;
      case 'critical':
        return ConflictSeverity.critical;
      default:
        return ConflictSeverity.safe;
    }
  }

  Map<String, dynamic> toJson() => {
    'ingredient_a': ingredientA,
    'ingredient_b': ingredientB,
    'severity': severity.name,
    'description': description,
    'recommendation': recommendation,
  };
}
