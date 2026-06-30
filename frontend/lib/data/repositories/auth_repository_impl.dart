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
    final response = await _remote.post<dynamic>(
      ApiConstants.login,
      data: {'usr': email, 'pwd': password},
    );
    if (response.isSuccess) {
      await _generateAndStoreApiKeys();
      final profile = await _remote.get<Map<String, dynamic>>(
        ApiConstants.getProfile,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      if (profile.isSuccess && profile.data != null) {
        final user = UserModel.fromJson(profile.data!);
        await _local.saveMap('user_data', profile.data!);
        return user;
      }
      return UserModel(
        id: email,
        name: email,
        email: email,
      );
    }
    throw ApiException(message: response.message ?? 'Login failed');
  }

  @override
  Future<User> register(String email, String password, String name) async {
    final names = name.split(' ');
    final response = await _remote.post<dynamic>(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'first_name': names.isNotEmpty ? names.first : name,
        'last_name': names.length > 1 ? names.sublist(1).join(' ') : '',
      },
    );
    if (response.isSuccess) {
      await _loginAfterRegister(email, password);
      await _generateAndStoreApiKeys();
      return UserModel(
        id: email,
        name: name,
        email: email,
      );
    }
    throw ApiException(message: response.message ?? 'Registration failed');
  }

  Future<void> _loginAfterRegister(String email, String password) async {
    final loginResponse = await _remote.post<dynamic>(
      ApiConstants.login,
      data: {'usr': email, 'pwd': password},
    );
    if (!loginResponse.isSuccess) {
      throw ApiException(message: loginResponse.message ?? 'Auto-login after registration failed');
    }
  }

  Future<void> _generateAndStoreApiKeys() async {
    final keyResponse = await _remote.post<Map<String, dynamic>>(
      ApiConstants.generateKeys,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (keyResponse.isSuccess && keyResponse.data != null) {
      final apiKey = keyResponse.data!['api_key'] as String?;
      final apiSecret = keyResponse.data!['api_secret'] as String?;
      if (apiKey != null && apiSecret != null) {
        await _api.setApiCredentials(apiKey, apiSecret);
      }
    }
  }

  @override
  Future<void> logout() async {
    await _remote.post(ApiConstants.logout);
    await _api.clearTokens();
    await _local.delete('user_data');
  }

  @override
  Future<bool> checkAuth() async {
    try {
      final creds = await _api.getApiCredentials();
      if (creds == null) return false;
      final response = await _remote.get<Map<String, dynamic>>(
        ApiConstants.getProfile,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> saveOnboardingData(OnboardingData data) async {
    await _remote.post(
      ApiConstants.updateProfile,
      data: {
        'full_name': data.name,
        'age_range': data.ageRange,
        'gender': data.gender,
        'country': data.country,
        'climate': data.climate,
        'skin_type': data.skinType,
        'skin_sensitivity': data.sensitivity,
        'hair_type': data.hairType,
      },
    );
    await _remote.post(ApiConstants.submitAssessment, data: {
      'assessment_type': 'Skin',
      'data': {
        'condition_score': 0,
        'severity': 0,
        'sensitivity': data.sensitivity == 'High' ? 2 : data.sensitivity == 'Medium' ? 1 : 0,
      },
    });
    await _remote.post(ApiConstants.submitAssessment, data: {
      'assessment_type': 'Hair',
      'data': {
        'condition_score': 0,
        'severity': 0,
        'scalp_condition': data.scalpCondition,
      },
    });
    await _remote.post(ApiConstants.submitAssessment, data: {
      'assessment_type': 'Lifestyle',
      'data': {
        'sleep_quality': data.sleepQuality,
        'stress_level': data.stressLevel,
        'diet_quality': 'Fair',
      },
    });
    await _local.saveString('onboarding_complete', 'true');
  }
}
