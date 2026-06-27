import 'package:equatable/equatable.dart';

class OnboardingData extends Equatable {
  final String name;
  final String ageRange;
  final String gender;
  final String country;
  final String climate;
  final String skinType;
  final String sensitivity;
  final String acne;
  final String pigmentation;
  final String wrinkles;
  final List<String> skinGoals;
  final String hairType;
  final String texture;
  final String thickness;
  final String density;
  final String scalpCondition;
  final List<String> hairIssues;
  final List<String> hairGoals;
  final String sleepQuality;
  final String waterIntake;
  final String activityLevel;
  final String stressLevel;
  final String sunExposure;

  const OnboardingData({
    this.name = '',
    this.ageRange = '',
    this.gender = '',
    this.country = '',
    this.climate = '',
    this.skinType = '',
    this.sensitivity = '',
    this.acne = '',
    this.pigmentation = '',
    this.wrinkles = '',
    this.skinGoals = const [],
    this.hairType = '',
    this.texture = '',
    this.thickness = '',
    this.density = '',
    this.scalpCondition = '',
    this.hairIssues = const [],
    this.hairGoals = const [],
    this.sleepQuality = '',
    this.waterIntake = '',
    this.activityLevel = '',
    this.stressLevel = '',
    this.sunExposure = '',
  });

  @override
  List<Object?> get props => [
    name, ageRange, gender, country, climate,
    skinType, sensitivity, acne, pigmentation, wrinkles, skinGoals,
    hairType, texture, thickness, density, scalpCondition, hairIssues, hairGoals,
    sleepQuality, waterIntake, activityLevel, stressLevel, sunExposure,
  ];
}
