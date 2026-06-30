import '../../domain/entities/diary_entry.dart';

class DiaryEntryModel extends DiaryEntry {
  const DiaryEntryModel({
    required super.id,
    required super.date,
    super.moodLevel,
    super.skinCondition,
    super.sleepHours,
    super.waterIntake,
    super.stressLevel,
    super.breakoutLocation,
    super.notes,
    super.photoUrl,
  });

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) {
    return DiaryEntryModel(
      id: json['name'] as String? ?? '',
      date: json['entry_date'] != null
          ? DateTime.parse(json['entry_date'] as String)
          : DateTime.now(),
      moodLevel: json['mood_level'] as int? ?? 2,
      skinCondition: json['skin_condition'] as String?,
      sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 7,
      waterIntake: json['water_intake'] as int? ?? 1,
      stressLevel: json['stress_level'] as int? ?? 1,
      breakoutLocation: json['breakout_location'] as String?,
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'entry_date': date.toIso8601String(),
    'mood_level': moodLevel,
    'skin_condition': skinCondition,
    'sleep_hours': sleepHours,
    'water_intake': waterIntake,
    'stress_level': stressLevel,
    'breakout_location': breakoutLocation,
    'notes': notes,
    'photo_url': photoUrl,
  };
}
