import '../core/base/base_model.dart';

/// Immutable comment model.
class Comment extends BaseModel {
  final String _id;
  final String _postId;
  final String _userId;
  final String _text;
  final DateTime _createdAt;

  // ── Named constructor ───────────────────────────────────────────────────

  Comment({
    required String id,
    required String postId,
    required String userId,
    required String text,
    required DateTime createdAt,
  })  : _id = id,
        _postId = postId,
        _userId = userId,
        _text = text,
        _createdAt = createdAt;

  // ── Factory from JSON ───────────────────────────────────────────────────

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // ── Getters ─────────────────────────────────────────────────────────────

  @override
  String get id => _id;
  String get postId => _postId;
  String get userId => _userId;
  String get text => _text;
  DateTime get createdAt => _createdAt;

  // ── Serialisation ───────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'post_id': _postId,
      'user_id': _userId,
      'text': _text,
      'created_at': _createdAt.toIso8601String(),
    };
  }

  // ── Copy-with ───────────────────────────────────────────────────────────

  Comment copyWith({
    String? text,
  }) {
    return Comment(
      id: _id,
      postId: _postId,
      userId: _userId,
      text: text ?? _text,
      createdAt: _createdAt,
    );
  }
}
