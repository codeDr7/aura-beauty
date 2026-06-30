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
    final nameValue = json['name'] as String? ?? '';
    return UserModel(
      id: nameValue,
      name: json['full_name'] as String? ?? nameValue,
      email: nameValue,
      avatarUrl: json['avatar_url'] as String?,
      skinType: json['skin_type'] as String?,
      hairType: json['hair_type'] as String?,
      skinConcerns: json['skin_concerns'] as String?,
      hairConcerns: json['hair_concerns'] as String?,
      sensitivity: json['skin_sensitivity'] as String?,
      skinScore: json['skin_score'] as int? ?? 0,
      hairScore: json['hair_score'] as int? ?? 0,
      subscriptionTier: json['subscription_status'] as String? ?? 'Free',
      subscriptionRenewal: json['subscription_renewal'] != null
          ? DateTime.tryParse(json['subscription_renewal'] as String)
          : null,
      memberSince: json['created_date'] != null
          ? DateTime.tryParse(json['created_date'] as String) ?? DateTime.now()
          : DateTime.now(),
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'full_name': name,
    'skin_type': skinType,
    'hair_type': hairType,
    'skin_concerns': skinConcerns,
    'hair_concerns': hairConcerns,
    'skin_sensitivity': sensitivity,
    'skin_score': skinScore,
    'hair_score': hairScore,
    'created_date': memberSince.toIso8601String(),
  };
}
