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
    if (brand != null && brand != 'All Brands') params['brand'] = brand;
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.products,
      queryParameters: params.isNotEmpty ? params : null,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) =>
              MarketplaceProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load products');
  }

  @override
  Future<List<PartnerOrder>> getOrders() async {
    final response = await _remote.get<List<dynamic>>(
      '${ApiConstants.notifications}/orders',
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
      '${ApiConstants.notifications}/partner',
      data: PartnerRegistrationModel(
        companyName: registration.companyName,
        email: registration.email,
        contactPerson: registration.contactPerson,
        integrationType: registration.integrationType,
      ).toJson(),
    );
  }

  @override
  Future<ApiCredentials> getApiCredentials() async {
    final response = await _remote.get<Map<String, dynamic>>(
      '${ApiConstants.notifications}/partner/credentials',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return ApiCredentialsModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to load credentials');
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _remote.put(
      '${ApiConstants.notifications}/orders/$orderId',
      data: {'status': status},
    );
  }
}

