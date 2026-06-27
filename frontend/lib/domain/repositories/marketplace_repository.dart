import '../entities/marketplace.dart';
import '../entities/product.dart';

abstract class MarketplaceRepository {
  Future<List<MarketplaceProduct>> getProducts({String? brand});
  Future<List<PartnerOrder>> getOrders();
  Future<void> registerPartner(PartnerRegistration registration);
  Future<ApiCredentials> getApiCredentials();
  Future<void> updateOrderStatus(String orderId, String status);
}
