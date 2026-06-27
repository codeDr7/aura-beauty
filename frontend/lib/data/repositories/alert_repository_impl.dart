import '../../core/constants/api_constants.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/price_alert_model.dart';

class AlertRepositoryImpl implements AlertRepository {
  final RemoteDataSource _remote;

  AlertRepositoryImpl(this._remote);

  @override
  Future<List<PriceAlert>> getAlerts() async {
    final response = await _remote.get<List<dynamic>>(
      '${ApiConstants.notifications}/price-alerts',
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => PriceAlertModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load alerts');
  }

  @override
  Future<PriceAlert> createAlert(PriceAlert alert) async {
    final response = await _remote.post<Map<String, dynamic>>(
      '${ApiConstants.notifications}/price-alerts',
      data: PriceAlertModel(
        id: alert.id,
        productName: alert.productName,
        brand: alert.brand,
        currentPrice: alert.currentPrice,
        targetPrice: alert.targetPrice,
        originalPrice: alert.originalPrice,
        isActive: alert.isActive,
      ).toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return PriceAlertModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to create alert');
  }

  @override
  Future<void> toggleAlert(String id, bool isActive) async {
    await _remote.put(
      '${ApiConstants.notifications}/price-alerts/$id',
      data: {'is_active': isActive},
    );
  }

  @override
  Future<void> deleteAlert(String id) async {
    await _remote.delete('${ApiConstants.notifications}/price-alerts/$id');
  }
}

