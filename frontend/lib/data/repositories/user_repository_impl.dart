import '../../core/constants/api_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource _remote;
  final LocalDataSource _local;

  UserRepositoryImpl(this._remote, this._local);

  @override
  Future<User> getProfile() async {
    try {
      final response = await _remote.get<Map<String, dynamic>>(
        ApiConstants.getProfile,
        fromJson: (json) => json as Map<String, dynamic>,
      );
      if (response.isSuccess && response.data != null) {
        final user = UserModel.fromJson(response.data!);
        await _local.saveMap('user_data', response.data!);
        return user;
      }
    } catch (_) {}
    final cached = await _local.getMap('user_data');
    if (cached != null) {
      return UserModel.fromJson(cached);
    }
    throw ApiException(message: 'Failed to load profile');
  }

  @override
  Future<User> updateProfile(User user) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.updateProfile,
      data: {
        'full_name': user.name,
        'skin_type': user.skinType,
        'skin_sensitivity': user.sensitivity,
        'hair_type': user.hairType,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return UserModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Update failed');
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    throw ApiException(message: 'Password change not available');
  }

  @override
  Future<void> deleteAccount() async {
    throw ApiException(message: 'Account deletion not available');
  }
}
