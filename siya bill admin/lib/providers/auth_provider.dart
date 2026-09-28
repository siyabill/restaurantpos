import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_provider.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? email;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.email,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? email,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      errorMessage: errorMessage, // We reset error unless provided
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthState()) {
    // Check if user is already logged in
    final svc = _ref.read(supabaseServiceProvider);
    final current = svc.currentEmail;
    if (current != null) {
      state = AuthState(isAuthenticated: true, email: current);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _ref.read(supabaseServiceProvider).signIn(email, password);
      if (success) {
        state = AuthState(isAuthenticated: true, email: email);
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Authentication failed.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(supabaseServiceProvider).signOut();
    } catch (_) {}
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
