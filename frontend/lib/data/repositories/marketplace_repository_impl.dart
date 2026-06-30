import '../../core/constants/api_constants.dart';
import '../../domain/entities/marketplace.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/marketplace_model.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final RemoteDataSource _remote;

  MarketplaceRepositoryImpl(this._remote);

  @override
  Future<List<MarketplaceProduct>> getProducts({String? brand}) async {
    final params = <String, dynamic>{};
    if (brand != null && brand != 'All Brands') params['filters'] = '{"brand":"$brand"}';
    final response = await _remote.get<Map<String, dynamic>>(
      ApiConstants.getProducts,
      queryParameters: params.isNotEmpty ? params : null,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      final list = response.data!['products'] as List<dynamic>? ??
          response.data!['message'] as List<dynamic>? ??
          [];
      return list
          .map((e) => MarketplaceProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load products');
  }

  @override
  Future<List<PartnerOrder>> getOrders() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.partnerGetOrders,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => PartnerOrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load orders');
  }

  @override
  Future<void> registerPartner(PartnerRegistration registration) async {
    await _remote.post(
      ApiConstants.partnerRegister,
      data: {
        'company_name': registration.companyName,
        'contact_email': registration.email,
        'contact_person': registration.contactPerson,
        'integration_type': registration.integrationType,
      },
    );
  }

  @override
  Future<ApiCredentials> getApiCredentials() async {
    throw ApiException(message: 'Credentials provided at registration time');
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _remote.post(
      ApiConstants.partnerUpdateOrderStatus,
      data: {'order_id': orderId, 'status': status},
    );
  }
}
