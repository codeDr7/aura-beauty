import '../entities/subscription_plan.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> getPlans();
  Future<SubscriptionPlan> getCurrentSubscription();
  Future<String> upgradePlan(String planId, {bool isAnnual = true});
  Future<void> cancelSubscription();
}
