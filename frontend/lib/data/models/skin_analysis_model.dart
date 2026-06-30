import '../../domain/entities/skin_analysis.dart';

class SkinAnalysisModel extends SkinAnalysis {
  const SkinAnalysisModel({
    required super.id,
    required super.date,
    required super.overallScore,
    required super.metrics,
    super.summary,
    super.recommendations,
  });

  factory SkinAnalysisModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('needs')) {
      final needs = json['needs'] as List<dynamic>? ?? [];
      return SkinAnalysisModel(
        id: json['name'] as String? ?? '',
        date: DateTime.now(),
        overallScore: needs.isEmpty ? 0 : 10 - needs.length,
        metrics: needs.asMap().entries.map((e) => SkinMetricModel(
          label: (e.value as Map<String, dynamic>)['area'] as String? ?? 'Unknown',
          score: e.key < 2 ? 5 - e.key : 3,
          iconName: (e.value as Map<String, dynamic>)['priority'] as String?,
        )).toList(),
        summary: json['profile_complete'] == true ? 'Profile complete' : 'Needs assessment',
        recommendations: needs.map((n) => (n as Map<String, dynamic>)['message'] as String? ?? '')
            .where((m) => m.isNotEmpty)
            .toList(),
      );
    }
    return SkinAnalysisModel(
      id: json['name'] as String? ?? '',
      date: json['assessment_date'] != null
          ? DateTime.parse(json['assessment_date'] as String)
          : DateTime.now(),
      overallScore: json['overall_score'] as int? ?? 0,
      metrics: (json['metrics'] as List<dynamic>?)
              ?.map((m) => SkinMetricModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as String?,
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'assessment_date': date.toIso8601String(),
    'overall_score': overallScore,
    'metrics': (metrics as List<SkinMetricModel>).map((m) => m.toJson()).toList(),
    'summary': summary,
    'recommendations': recommendations,
  };
}

class SkinMetricModel extends SkinMetric {
  const SkinMetricModel({
    required super.label,
    required super.score,
    super.iconName,
  });

  factory SkinMetricModel.fromJson(Map<String, dynamic> json) {
    return SkinMetricModel(
      label: json['label'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      iconName: json['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'score': score,
    'icon_name': iconName,
  };
}
