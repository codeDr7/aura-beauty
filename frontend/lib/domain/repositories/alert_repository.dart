import '../entities/price_alert.dart';

abstract class AlertRepository {
  Future<List<PriceAlert>> getAlerts();
  Future<PriceAlert> createAlert(PriceAlert alert);
  Future<void> toggleAlert(String id, bool isActive);
  Future<void> deleteAlert(String id);
}
