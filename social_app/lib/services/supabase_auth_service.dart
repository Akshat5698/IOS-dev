import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../core/base/base_repository.dart';
import '../core/base/base_service.dart';
import '../models/user.dart';

class SupabaseUserRepository extends BaseRepository<User> {
  final supabase.SupabaseClient _client;

  SupabaseUserRepository(this._client);

  @override
  String get tableName => 'profiles';

  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Future<List<User>> fetchAll({String orderBy = 'created_at', bool ascending = false, int? limit}) async {
    if (limit != null) {
      final response = await _client.from(tableName).select().order(orderBy, ascending: ascending).limit(limit);
      return response.map((json) => fromJson(json)).toList();
    } else {
      final response = await _client.from(tableName).select().order(orderBy, ascending: ascending);
      return response.map((json) => fromJson(json)).toList();
    }
  }

  @override
  Future<User?> fetchById(String id) async {
    try {
      final response = await _client.from(tableName).select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<User>> fetchWhere(Map<String, dynamic> filters) async {
    var query = _client.from(tableName).select();
    for (final entry in filters.entries) {
      query = query.eq(entry.key, entry.value);
    }
    final response = await query;
    return response.map((json) => fromJson(json)).toList();
  }

  @override
  Future<User> create(Map<String, dynamic> data) async {
    throw UnimplementedError('Profiles are created via database trigger on signup.');
  }

  @override
  Future<User> update(String id, Map<String, dynamic> data) async {
    final response = await _client.from(tableName).update(data).eq('id', id).select().single();
    return fromJson(response);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }
}

class SupabaseAuthService extends BaseService<User> {
  final supabase.SupabaseClient _client;
  final SupabaseUserRepository _repository;

  SupabaseAuthService(this._client) : _repository = SupabaseUserRepository(_client);

  @override
  BaseRepository<User> get repository => _repository;

  /// Listen to Supabase Auth state changes
  Stream<supabase.AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Login with email and password
  Future<User?> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    if (response.user != null) {
      return await _repository.fetchById(response.user!.id);
    }
    return null;
  }

  /// Signup with email and password (must be gmail)
  Future<User?> signup(String email, String password) async {
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      throw Exception('Signups are restricted to @gmail.com addresses only.');
    }
    
    final response = await _client.auth.signUp(email: email, password: password);
    if (response.user != null) {
      // Profile creation is handled by Postgres trigger on auth.users insert.
      // We might need to wait slightly for the trigger to finish before fetching.
      await Future.delayed(const Duration(milliseconds: 500));
      return await _repository.fetchById(response.user!.id);
    }
    return null;
  }

  /// Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Get current signed in user
  Future<User?> getCurrentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    return await _repository.fetchById(authUser.id);
  }
}
