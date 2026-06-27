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
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.productIngredients,
      queryParameters: {'q': query},
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!.map((e) => e as String).toList();
    }
    throw ApiException(message: response.message ?? 'Search failed');
  }

  @override
  Future<List<IngredientInteraction>> checkInteractions(List<String> ingredients) async {
    final response = await _remote.post<List<dynamic>>(
      '${ApiConstants.productIngredients}/check',
      data: {'ingredients': ingredients},
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) =>
              IngredientInteractionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Check failed');
  }

  @override
  Future<Map<String, String>> getIngredientDetails(String ingredient) async {
    final response = await _remote.get<Map<String, dynamic>>(
      '${ApiConstants.productIngredients}/$ingredient',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!.map((k, v) => MapEntry(k, v.toString()));
    }
    throw ApiException(message: response.message ?? 'Ingredient not found');
  }
}

