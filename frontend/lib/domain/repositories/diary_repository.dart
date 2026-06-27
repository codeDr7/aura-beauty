import '../entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>> getEntries();
  Future<DiaryEntry> createEntry(DiaryEntry entry);
  Future<void> deleteEntry(String id);
}
