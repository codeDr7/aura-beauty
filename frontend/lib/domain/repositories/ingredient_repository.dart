import '../entities/ingredient_interaction.dart';

abstract class IngredientRepository {
  Future<List<String>> searchIngredients(String query);
  Future<List<IngredientInteraction>> checkInteractions(List<String> ingredients);
  Future<Map<String, String>> getIngredientDetails(String ingredient);
}
