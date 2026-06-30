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
  Future<List<ProgressEntry>> getEntries({int limit = 30}) async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getProgress,
      queryParameters: {'limit': limit},
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => ProgressEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load progress');
  }

  @override
  Future<void> logEntry({
    required String entryType,
    int value = 0,
    String? notes,
  }) async {
    await _remote.post(ApiConstants.logProgress, data: {
      'entry_type': entryType,
      'value': value,
      if (notes != null) 'notes': notes,
    });
  }
}
