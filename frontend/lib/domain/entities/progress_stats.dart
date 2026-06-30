import 'package:equatable/equatable.dart';

class ProgressStats extends Equatable {
  final int streak;
  final int totalEntries;
  final double improvement;
  final int skinScore;
  final int hairScore;
  final List<ScorePoint> scoreTrend;
  final List<ActivityEntry> recentActivity;

  const ProgressStats({
    this.streak = 0,
    this.totalEntries = 0,
    this.improvement = 0.0,
    this.skinScore = 0,
    this.hairScore = 0,
    this.scoreTrend = const [],
    this.recentActivity = const [],
  });

  @override
  List<Object?> get props => [streak, totalEntries, improvement, skinScore, hairScore, scoreTrend, recentActivity];
}

class ScorePoint extends Equatable {
  final double day;
  final double score;

  const ScorePoint({required this.day, required this.score});

  @override
  List<Object?> get props => [day, score];
}

class ActivityEntry extends Equatable {
  final String date;
  final String title;
  final String subtitle;
  final String iconName;
  final String colorName;

  const ActivityEntry({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.colorName,
  });

  @override
  List<Object?> get props => [date, title, subtitle, iconName, colorName];
}

class ProgressEntry extends Equatable {
  final String name;
  final String entryDate;
  final String entryType;
  final int value;
  final String? notes;
  final String? image;

  const ProgressEntry({
    this.name = '',
    this.entryDate = '',
    this.entryType = 'Diary',
    this.value = 0,
    this.notes,
    this.image,
  });

  @override
  List<Object?> get props => [name, entryDate, entryType, value, notes ?? '', image ?? ''];
}
