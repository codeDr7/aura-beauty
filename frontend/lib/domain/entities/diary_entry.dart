import 'package:equatable/equatable.dart';

class DiaryEntry extends Equatable {
  final String id;
  final DateTime date;
  final int moodLevel;
  final String? skinCondition;
  final double sleepHours;
  final int waterIntake;
  final int stressLevel;
  final String? breakoutLocation;
  final String? notes;
  final String? photoUrl;

  const DiaryEntry({
    required this.id,
    required this.date,
    this.moodLevel = 2,
    this.skinCondition,
    this.sleepHours = 7,
    this.waterIntake = 1,
    this.stressLevel = 1,
    this.breakoutLocation,
    this.notes,
    this.photoUrl,
  });

  String get formattedDate {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  List<Object?> get props => [
    id, date, moodLevel, skinCondition, sleepHours,
    waterIntake, stressLevel, breakoutLocation, notes, photoUrl,
  ];
}
