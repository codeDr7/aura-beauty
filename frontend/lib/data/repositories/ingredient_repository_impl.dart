import '../../core/constants/api_constants.dart';
import '../../domain/entities/ingredient_interaction.dart';
import '../../domain/repositories/ingredient_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/ingredient_interaction_model.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final RemoteDataSource _remote;

  IngredientRepositoryImpl(this._remote);

  @override
  Future<List<String>> searchIngredients(String query) async {
    final all = await getAllIngredients();
    if (query.isEmpty) return all;
    final lower = query.toLowerCase();
    return all.where((name) => name.toLowerCase().contains(lower)).toList();
  }

  Future<List<String>> getAllIngredients() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getIngredients,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => (e as Map<String, dynamic>)['ingredient_name'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
    }
    return [];
  }

  @override
  Future<List<IngredientInteraction>> checkInteractions(List<String> ingredients) async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getIngredientConflicts,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      final allConflicts = response.data!
          .map((e) => IngredientInteractionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return allConflicts.where((c) =>
          ingredients.contains(c.ingredientA) || ingredients.contains(c.ingredientB)
      ).toList();
    }
    throw ApiException(message: response.message ?? 'Check failed');
  }

  @override
  Future<Map<String, String>> getIngredientDetails(String ingredient) async {
    throw ApiException(message: 'Not available');
  }
}
