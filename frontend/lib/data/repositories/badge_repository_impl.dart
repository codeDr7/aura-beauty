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
  Future<List<Badge>> getBadges({String? category}) async {
    final params = <String, dynamic>{};
    if (category != null && category != 'All') params['category'] = category;
    final response = await _remote.get<List<dynamic>>(
      '${ApiConstants.notifications}/badges',
      queryParameters: params.isNotEmpty ? params : null,
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
  Future<List<String>> getCategories() async {
    final response = await _remote.get<List<dynamic>>(
      '${ApiConstants.notifications}/badges/categories',
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!.map((e) => e as String).toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load categories');
  }
}

