import '../entities/progress_stats.dart';

abstract class ProgressRepository {
  Future<List<ProgressEntry>> getEntries({int limit = 30});
  Future<void> logEntry({required String entryType, int value = 0, String? notes});
}
