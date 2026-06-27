import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? skinType;
  final String? hairType;
  final String? skinConcerns;
  final String? hairConcerns;
  final String? sensitivity;
  final int skinScore;
  final int hairScore;
  final String? subscriptionTier;
  final DateTime? subscriptionRenewal;
  final DateTime memberSince;
  final bool onboardingComplete;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.skinType,
    this.hairType,
    this.skinConcerns,
    this.hairConcerns,
    this.sensitivity,
    this.skinScore = 0,
    this.hairScore = 0,
    this.subscriptionTier,
    this.subscriptionRenewal,
    DateTime? memberSince,
    this.onboardingComplete = false,
  }) : memberSince = memberSince ?? DateTime.now();

  @override
  List<Object?> get props => [
    id, name, email, avatarUrl, skinType, hairType,
    skinConcerns, hairConcerns, sensitivity, skinScore,
    hairScore, subscriptionTier, subscriptionRenewal,
    memberSince, onboardingComplete,
  ];
}
