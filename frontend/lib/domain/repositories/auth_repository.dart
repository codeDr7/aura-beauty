import '../entities/user.dart';
import '../entities/onboarding_data.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String email, String password, String name);
  Future<void> logout();
  Future<bool> checkAuth();
  Future<void> saveOnboardingData(OnboardingData data);
}
