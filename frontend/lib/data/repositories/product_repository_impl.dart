import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final RemoteDataSource _remote;

  ProductRepositoryImpl(this._remote);

  @override
  Future<List<Product>> getProducts({String? category, String? brand}) async {
    final filterMap = <String, dynamic>{};
    if (category != null && category != 'All') filterMap['category'] = category;
    final queryParams = filterMap.isNotEmpty ? {'filters': jsonEncode(filterMap)} : null;
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getProducts,
      queryParameters: queryParams,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load products');
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.searchProducts,
      queryParameters: {'query': query},
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Search failed');
  }

  @override
  Future<Product> getProductById(String id) async {
    final response = await _remote.get<Map<String, dynamic>>(
      ApiConstants.getProduct,
      queryParameters: {'name': id},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return ProductModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Product not found');
  }

  @override
  Future<List<Product>> getRecommendations() async {
    final response = await _remote.get<Map<String, dynamic>>(
      ApiConstants.getRecommendations,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      final products = response.data!['products'] as List<dynamic>? ?? [];
      return products
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load recommendations');
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _remote.get<Map<String, dynamic>>(
      ApiConstants.beautyProduct,
      queryParameters: {'fields': '["category"]'},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => (e as Map<String, dynamic>)['category'] as String? ?? '')
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
    }
    return [];
  }
}
