import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String name;
  final String email;
  final String memberSince;
  final String skinType;
  final String hairType;
  final String concerns;
  final String sensitivity;
  final int skinScore;
  final int hairScore;
  final String subscriptionTier;
  final DateTime? subscriptionRenewal;

  const UserProfile({
    this.name = 'Sarah A.',
    this.email = 'sarah@example.com',
    this.memberSince = 'January 2026',
    this.skinType = 'Combination',
    this.hairType = 'Wavy',
    this.concerns = 'Hydration, Aging',
    this.sensitivity = 'Mild',
    this.skinScore = 72,
    this.hairScore = 65,
    this.subscriptionTier = 'Aura Plus',
    this.subscriptionRenewal,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? memberSince,
    String? skinType,
    String? hairType,
    String? concerns,
    String? sensitivity,
    int? skinScore,
    int? hairScore,
    String? subscriptionTier,
    DateTime? subscriptionRenewal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      memberSince: memberSince ?? this.memberSince,
      skinType: skinType ?? this.skinType,
      hairType: hairType ?? this.hairType,
      concerns: concerns ?? this.concerns,
      sensitivity: sensitivity ?? this.sensitivity,
      skinScore: skinScore ?? this.skinScore,
      hairScore: hairScore ?? this.hairScore,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionRenewal: subscriptionRenewal ?? this.subscriptionRenewal,
    );
  }
}

class ProfileState {
  final UserProfile userProfile;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.userProfile = const UserProfile(),
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? userProfile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isLoading: false);
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(userProfile: updatedProfile, isLoading: false);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
