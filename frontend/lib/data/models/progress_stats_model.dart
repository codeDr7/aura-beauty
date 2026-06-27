import '../../domain/entities/progress_stats.dart';

class ProgressStatsModel extends ProgressStats {
  const ProgressStatsModel({
    super.streak,
    super.totalEntries,
    super.improvement,
    super.skinScore,
    super.hairScore,
    super.scoreTrend,
    super.recentActivity,
  });

  factory ProgressStatsModel.fromJson(Map<String, dynamic> json) {
    return ProgressStatsModel(
      streak: json['streak'] as int? ?? 0,
      totalEntries: json['total_entries'] as int? ?? 0,
      improvement: (json['improvement'] as num?)?.toDouble() ?? 0.0,
      skinScore: json['skin_score'] as int? ?? 0,
      hairScore: json['hair_score'] as int? ?? 0,
      scoreTrend: (json['score_trend'] as List<dynamic>?)
              ?.map((s) => ScorePointModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      recentActivity: (json['recent_activity'] as List<dynamic>?)
              ?.map((a) => ActivityEntryModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'streak': streak,
    'total_entries': totalEntries,
    'improvement': improvement,
    'skin_score': skinScore,
    'hair_score': hairScore,
    'score_trend': (scoreTrend as List<ScorePointModel>).map((s) => s.toJson()).toList(),
    'recent_activity': (recentActivity as List<ActivityEntryModel>).map((a) => a.toJson()).toList(),
  };
}

class ScorePointModel extends ScorePoint {
  const ScorePointModel({required super.day, required super.score});

  factory ScorePointModel.fromJson(Map<String, dynamic> json) {
    return ScorePointModel(
      day: (json['day'] as num?)?.toDouble() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'day': day, 'score': score};
}

class ActivityEntryModel extends ActivityEntry {
  const ActivityEntryModel({
    required super.date,
    required super.title,
    required super.subtitle,
    required super.iconName,
    required super.colorName,
  });

  factory ActivityEntryModel.fromJson(Map<String, dynamic> json) {
    return ActivityEntryModel(
      date: json['date'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? '',
      colorName: json['color_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'title': title,
    'subtitle': subtitle,
    'icon_name': iconName,
    'color_name': colorName,
  };
}
