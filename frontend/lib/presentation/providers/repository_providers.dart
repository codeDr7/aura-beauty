import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/remote_data_source.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/routine_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/community_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../data/repositories/diary_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../data/repositories/analysis_repository_impl.dart';
import '../../data/repositories/ingredient_repository_impl.dart';
import '../../data/repositories/alert_repository_impl.dart';
import '../../data/repositories/ai_coach_repository_impl.dart';
import '../../data/repositories/marketplace_repository_impl.dart';
import '../../data/repositories/badge_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/routine_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../../domain/repositories/ingredient_repository.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../domain/repositories/ai_coach_repository.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../../domain/repositories/badge_repository.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return RemoteDataSource(ref.watch(apiClientProvider));
});

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource(ref.watch(secureStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(remoteDataSourceProvider),
    ref.watch(localDataSourceProvider),
    ref.watch(apiClientProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    ref.watch(remoteDataSourceProvider),
    ref.watch(localDataSourceProvider),
  );
});

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepositoryImpl(
    ref.watch(remoteDataSourceProvider),
    ref.watch(localDataSourceProvider),
  );
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  return AnalysisRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  return IngredientRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final aiCoachRepositoryProvider = Provider<AiCoachRepository>((ref) {
  return AiCoachRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(ref.watch(remoteDataSourceProvider));
});

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  return BadgeRepositoryImpl(ref.watch(remoteDataSourceProvider));
});
