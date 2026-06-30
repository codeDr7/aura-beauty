import '../../core/constants/api_constants.dart';
import '../../domain/entities/badge.dart';
import '../../domain/repositories/badge_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/badge_model.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  final RemoteDataSource _remote;

  BadgeRepositoryImpl(this._remote);

  @override
  Future<List<Badge>> getMyBadges() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getMyBadges,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load badges');
  }

  @override
  Future<List<Badge>> getAllBadges() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getAllBadges,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => BadgeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load badges');
  }
}
