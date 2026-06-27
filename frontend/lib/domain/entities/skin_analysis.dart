import 'package:equatable/equatable.dart';

class SkinAnalysis extends Equatable {
  final String id;
  final DateTime date;
  final int overallScore;
  final List<SkinMetric> metrics;
  final String? summary;
  final List<String>? recommendations;

  const SkinAnalysis({
    required this.id,
    required this.date,
    required this.overallScore,
    required this.metrics,
    this.summary,
    this.recommendations,
  });

  @override
  List<Object?> get props => [id, date, overallScore, metrics, summary, recommendations];
}

class SkinMetric extends Equatable {
  final String label;
  final int score;
  final String? iconName;

  const SkinMetric({
    required this.label,
    required this.score,
    this.iconName,
  });

  @override
  List<Object?> get props => [label, score, iconName];
}
