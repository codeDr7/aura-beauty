import '../entities/user.dart';

abstract class UserRepository {
  Future<User> getProfile();
  Future<User> updateProfile(User user);
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount();
}
