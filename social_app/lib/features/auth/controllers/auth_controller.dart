import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';
import '../../../models/user.dart';

// ── State ─────────────────────────────────────────────────────────────────

/// Immutable auth state.
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────

/// Riverpod [StateNotifier] managing authentication state.
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final user = await _authService.getCurrentUser();
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: user != null,
      user: user,
    );
  }

  /// Sign up with email, password, and username.
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        username: username,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Sign in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email: email, password: password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Clear any displayed error.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

/// Singleton [AuthService] provider.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Auth state provider.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(authService: ref.watch(authServiceProvider));
});
