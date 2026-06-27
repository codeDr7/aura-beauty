import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    super.skinType,
    super.hairType,
    super.skinConcerns,
    super.hairConcerns,
    super.sensitivity,
    super.skinScore,
    super.hairScore,
    super.subscriptionTier,
    super.subscriptionRenewal,
    super.memberSince,
    super.onboardingComplete,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      skinType: json['skin_type'] as String?,
      hairType: json['hair_type'] as String?,
      skinConcerns: json['skin_concerns'] as String?,
      hairConcerns: json['hair_concerns'] as String?,
      sensitivity: json['sensitivity'] as String?,
      skinScore: json['skin_score'] as int? ?? 0,
      hairScore: json['hair_score'] as int? ?? 0,
      subscriptionTier: json['subscription_tier'] as String?,
      subscriptionRenewal: json['subscription_renewal'] != null
          ? DateTime.tryParse(json['subscription_renewal'] as String)
          : null,
      memberSince: json['member_since'] != null
          ? DateTime.parse(json['member_since'] as String)
          : DateTime.now(),
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
    'skin_type': skinType,
    'hair_type': hairType,
    'skin_concerns': skinConcerns,
    'hair_concerns': hairConcerns,
    'sensitivity': sensitivity,
    'skin_score': skinScore,
    'hair_score': hairScore,
    'subscription_tier': subscriptionTier,
    'subscription_renewal': subscriptionRenewal?.toIso8601String(),
    'member_since': memberSince.toIso8601String(),
    'onboarding_complete': onboardingComplete,
  };
}
