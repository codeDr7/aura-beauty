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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isEarned: json['is_earned'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'is_earned': isEarned,
    'progress': progress,
    'description': description,
    'icon_name': iconName,
  };
}
