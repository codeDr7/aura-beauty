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
        '${ApiConstants.notifications}/diary',
        fromJson: (json) => json as List<dynamic>,
      );
      if (response.isSuccess && response.data != null) {
        return response.data!
            .map((e) => DiaryEntryModel.fromJson(e as Map<String, dynamic>))
            .toList();
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
      '${ApiConstants.notifications}/diary',
      data: DiaryEntryModel(
        id: entry.id,
        date: entry.date,
        moodLevel: entry.moodLevel,
        skinCondition: entry.skinCondition,
        sleepHours: entry.sleepHours,
        waterIntake: entry.waterIntake,
        stressLevel: entry.stressLevel,
        breakoutLocation: entry.breakoutLocation,
        notes: entry.notes,
        photoUrl: entry.photoUrl,
      ).toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return DiaryEntryModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to create entry');
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _remote.delete('${ApiConstants.notifications}/diary/$id');
  }
}

