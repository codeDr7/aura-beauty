import '../../domain/entities/badge.dart';

class BadgeModel extends Badge {
  const BadgeModel({
    required super.id,
    required super.name,
    required super.category,
    super.isEarned,
    super.progress,
    super.description,
    super.iconName,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['badge'] as String? ?? json['name'] as String? ?? '',
      name: json['badge_name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isEarned: json['earned_date'] != null,
      progress: (json['points'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      iconName: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'badge_name': name,
    'icon': iconName,
    'description': description,
    'points': progress,
  };
}
