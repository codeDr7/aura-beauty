import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class AuthState {
  final String? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api = ApiClient();

  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      if (response.isSuccess && response.data != null) {
        final token = response.data!['token'] as String?;
        final refreshToken = response.data!['refresh_token'] as String?;
        final userName = response.data!['user']?['name'] as String? ?? email;
        if (token != null) {
          await _api.setToken(token);
        }
        if (refreshToken != null) {
          await _api.setRefreshToken(refreshToken);
        }
        state = state.copyWith(
          user: userName,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {'email': email, 'password': password, 'name': name},
      );
      if (response.isSuccess && response.data != null) {
        final token = response.data!['token'] as String?;
        final refreshToken = response.data!['refresh_token'] as String?;
        if (token != null) {
          await _api.setToken(token);
        }
        if (refreshToken != null) {
          await _api.setRefreshToken(refreshToken);
        }
        state = state.copyWith(
          user: name,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _api.clearTokens();
    state = const AuthState();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    final token = await _api.getToken();
    if (token != null) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: 'User',
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
