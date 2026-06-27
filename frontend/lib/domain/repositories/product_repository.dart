import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({String? category, String? brand});
  Future<List<Product>> searchProducts(String query);
  Future<Product> getProductById(String id);
  Future<List<Product>> getRecommendations();
  Future<List<String>> getCategories();
}
