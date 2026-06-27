import '../entities/progress_stats.dart';

abstract class ProgressRepository {
  Future<ProgressStats> getStats();
  Future<List<ScorePoint>> getScoreTrend({String period = 'weekly'});
  Future<List<ActivityEntry>> getRecentActivity();
}
