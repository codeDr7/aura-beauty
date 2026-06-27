import '../../core/constants/api_constants.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/subscription_plan_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final RemoteDataSource _remote;

  SubscriptionRepositoryImpl(this._remote);

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.subscriptionPlans,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load plans');
  }

  @override
  Future<SubscriptionPlan> getCurrentSubscription() async {
    final response = await _remote.get<Map<String, dynamic>>(
      ApiConstants.currentSubscription,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return SubscriptionPlanModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to load subscription');
  }

  @override
  Future<String> createCheckoutSession(String planId, {bool isAnnual = true}) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.createCheckoutSession,
      data: {'plan_id': planId, 'is_annual': isAnnual},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!['url'] as String? ?? '';
    }
    throw ApiException(message: response.message ?? 'Failed to create checkout');
  }

  @override
  Future<void> cancelSubscription() async {
    await _remote.post(ApiConstants.cancelSubscription);
  }
}

