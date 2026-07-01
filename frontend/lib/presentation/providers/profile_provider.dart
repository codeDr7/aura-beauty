import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import 'repository_providers.dart';

class ProfileState {
  final User? userProfile;
  final bool isLoading;
  final String? error;

  const ProfileState({this.userProfile, this.isLoading = false, this.error});

  ProfileState copyWith({User? userProfile, bool? isLoading, String? error}) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserRepository _userRepo;

  ProfileNotifier(this._userRepo) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userRepo.getProfile();
      state = state.copyWith(userProfile: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(User updatedProfile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userRepo.updateProfile(updatedProfile);
      state = state.copyWith(userProfile: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return ProfileNotifier(userRepo);
});
