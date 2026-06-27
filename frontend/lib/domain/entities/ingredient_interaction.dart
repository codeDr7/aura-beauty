import 'package:equatable/equatable.dart';

enum ConflictSeverity { safe, low, medium, high, critical }

class IngredientInteraction extends Equatable {
  final String ingredientA;
  final String ingredientB;
  final ConflictSeverity severity;
  final String description;
  final String recommendation;

  const IngredientInteraction({
    required this.ingredientA,
    required this.ingredientB,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  @override
  List<Object?> get props => [ingredientA, ingredientB, severity, description, recommendation];
}
