import '../../core/constants/api_constants.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/diary_entry_model.dart';
import 'dart:convert';

class DiaryRepositoryImpl implements DiaryRepository {
  final RemoteDataSource _remote;
  final LocalDataSource _local;

  DiaryRepositoryImpl(this._remote, this._local);

  @override
  Future<List<DiaryEntry>> getEntries() async {
    try {
      final response = await _remote.get<List<dynamic>>(
        ApiConstants.getProgress,
        queryParameters: {'limit': 50},
        fromJson: (json) => json as List<dynamic>,
      );
      if (response.isSuccess && response.data != null) {
        final entries = response.data!
            .map((e) => DiaryEntryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        await _local.saveString('diary_entries', jsonEncode(
          response.data!.map((e) => e as Map<String, dynamic>).toList(),
        ));
        return entries;
      }
    } catch (_) {}
    final cached = await _local.getString('diary_entries');
    if (cached != null) {
      final list = jsonDecode(cached) as List<dynamic>;
      return list
          .map((e) => DiaryEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<DiaryEntry> createEntry(DiaryEntry entry) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.logProgress,
      data: {
        'entry_type': 'Diary',
        'value': entry.moodLevel ?? 5,
        if (entry.notes != null) 'notes': entry.notes,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return DiaryEntryModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to create entry');
  }

  @override
  Future<void> deleteEntry(String id) async {
    throw ApiException(message: 'Not available');
  }
}
