import '../../core/constants/api_constants.dart';
import '../../domain/entities/progress_stats.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/progress_stats_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final RemoteDataSource _remote;

  ProgressRepositoryImpl(this._remote);

  @override
  Future<ProgressStats> getStats() async {
    final response = await _remote.get<Map<String, dynamic>>(
      ApiConstants.progressStats,
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return ProgressStatsModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to load stats');
  }

  @override
  Future<List<ScorePoint>> getScoreTrend({String period = 'weekly'}) async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.progressCharts,
      queryParameters: {'period': period},
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => ScorePointModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load trend');
  }

  @override
  Future<List<ActivityEntry>> getRecentActivity() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.progressTimeline,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => ActivityEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load activity');
  }
}

