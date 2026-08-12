import '../core/base/base_model.dart';

/// Immutable user / profile model.
///
/// All fields are private with public getters — no mutable state.
/// Use [copyWith] to derive modified copies.
class User extends BaseModel {
  final String _id;
  final String _username;
  final String _email;
  final String? _avatarUrl;
  final String? _bio;
  final int _followersCount;
  final int _followingCount;
  final DateTime _createdAt;

  // ── Named constructor ───────────────────────────────────────────────────

  User({
    required String id,
    required String username,
    required String email,
    String? avatarUrl,
    String? bio,
    int followersCount = 0,
    int followingCount = 0,
    required DateTime createdAt,
  })  : _id = id,
        _username = username,
        _email = email,
        _avatarUrl = avatarUrl,
        _bio = bio,
        _followersCount = followersCount,
        _followingCount = followingCount,
        _createdAt = createdAt;

  // ── Factory from JSON ───────────────────────────────────────────────────

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // ── Getters ─────────────────────────────────────────────────────────────

  @override
  String get id => _id;
  String get username => _username;
  String get email => _email;
  String? get avatarUrl => _avatarUrl;
  String? get bio => _bio;
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  DateTime get createdAt => _createdAt;

  // ── Serialisation ───────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'username': _username,
      'email': _email,
      'avatar_url': _avatarUrl,
      'bio': _bio,
      'followers_count': _followersCount,
      'following_count': _followingCount,
      'created_at': _createdAt.toIso8601String(),
    };
  }

  // ── Copy-with ───────────────────────────────────────────────────────────

  User copyWith({
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
  }) {
    return User(
      id: _id,
      username: username ?? _username,
      email: email ?? _email,
      avatarUrl: avatarUrl ?? _avatarUrl,
      bio: bio ?? _bio,
      followersCount: followersCount ?? _followersCount,
      followingCount: followingCount ?? _followingCount,
      createdAt: _createdAt,
    );
  }
}
