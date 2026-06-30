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
    throw ApiException(message: 'Not available');
  }

  @override
  Future<PriceAlert> createAlert(PriceAlert alert) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.setPriceAlert,
      data: {
        'product': alert.productName,
        'target_price': alert.targetPrice,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return PriceAlertModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to create alert');
  }

  @override
  Future<void> toggleAlert(String id, bool isActive) async {
    throw ApiException(message: 'Not available');
  }

  @override
  Future<void> deleteAlert(String id) async {
    throw ApiException(message: 'Not available');
  }
}
