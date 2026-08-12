import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../../models/user.dart';
import '../../../services/supabase_auth_service.dart';

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
  final SupabaseAuthService _authService;

  AuthController({required SupabaseAuthService authService})
      : _authService = authService,
        super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    
    // Listen to Supabase auth state changes for automatic routing
    _authService.authStateChanges.listen((event) async {
      final session = event.session;
      if (session == null) {
        if (mounted) {
          state = state.copyWith(isAuthenticated: false, user: null, isLoading: false);
        }
      } else {
        final user = await _authService.getCurrentUser();
        if (mounted) {
          state = state.copyWith(isAuthenticated: true, user: user, isLoading: false);
        }
      }
    });

    final user = await _authService.getCurrentUser();
    if (mounted) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: user != null,
        user: user,
      );
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? username, // username will be parsed in the postgres trigger
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.signup(email, password);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  /// Sign in with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email, password);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.logout();
      if (mounted) {
        state = const AuthState();
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  /// Clear any displayed error.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

/// Auth state provider.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(authService: ref.watch(supabaseAuthServiceProvider));
});
