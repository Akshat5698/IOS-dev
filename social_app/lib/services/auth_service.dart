import '../core/base/base_repository.dart';
import '../core/base/base_service.dart';
import '../models/user.dart';
import '../core/mock/mock_database.dart';

/// Mock authentication service.
class AuthService extends BaseService<User> {
  final MockDatabase _db = MockDatabase.instance;

  @override
  // ignore: null_check_always_fails
  BaseRepository<User> get repository => null!; // Not needed for mocked auth

  /// Logs in the user using the mock demo account, regardless of credentials.
  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _db.currentUser;
  }

  /// Signs up a new mock user (just returns the demo account).
  Future<User> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _db.currentUser;
  }

  /// Logs out the user.
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Fetches the current session user (if already logged in).
  Future<User?> getCurrentUser() async {
    // Return null to trigger the login flow
    return null;
  }
}
