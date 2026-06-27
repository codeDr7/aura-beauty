import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/onboarding_data.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remote;
  final LocalDataSource _local;
  final ApiClient _api;

  AuthRepositoryImpl(this._remote, this._local, this._api);

  @override
  Future<User> login(String email, String password) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'] as String?;
      final refreshToken = response.data!['refresh_token'] as String?;
      if (token != null) await _api.setToken(token);
      if (refreshToken != null) await _api.setRefreshToken(refreshToken);
      final userData = response.data!['user'] as Map<String, dynamic>?;
      if (userData != null) {
        final user = UserModel.fromJson(userData);
        await _local.saveMap('user_data', userData);
        return user;
      }
      return UserModel(
        id: response.data!['user_id'] as String? ?? '',
        name: response.data!['name'] as String? ?? email,
        email: email,
      );
    }
    throw ApiException(message: response.message ?? 'Login failed');
  }

  @override
  Future<User> register(String email, String password, String name) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {'email': email, 'password': password, 'name': name},
    );
    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'] as String?;
      final refreshToken = response.data!['refresh_token'] as String?;
      if (token != null) await _api.setToken(token);
      if (refreshToken != null) await _api.setRefreshToken(refreshToken);
      return UserModel(
        id: response.data!['user_id'] as String? ?? '',
        name: name,
        email: email,
      );
    }
    throw ApiException(message: response.message ?? 'Registration failed');
  }

  @override
  Future<void> logout() async {
    await _api.clearTokens();
    await _local.delete('user_data');
  }

  @override
  Future<bool> checkAuth() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveOnboardingData(OnboardingData data) async {
    await _remote.post(ApiConstants.saveSkinAssessment, data: {
      'skin_type': data.skinType,
      'sensitivity': data.sensitivity,
      'acne': data.acne,
      'pigmentation': data.pigmentation,
      'wrinkles': data.wrinkles,
      'goals': data.skinGoals,
    });
    await _remote.post(ApiConstants.saveHairAssessment, data: {
      'hair_type': data.hairType,
      'texture': data.texture,
      'thickness': data.thickness,
      'density': data.density,
      'scalp_condition': data.scalpCondition,
      'issues': data.hairIssues,
      'goals': data.hairGoals,
    });
    await _remote.post(ApiConstants.saveLifestyleAssessment, data: {
      'sleep_quality': data.sleepQuality,
      'water_intake': data.waterIntake,
      'activity_level': data.activityLevel,
      'stress_level': data.stressLevel,
      'sun_exposure': data.sunExposure,
    });
    await _local.saveString('onboarding_complete', 'true');
  }
}

