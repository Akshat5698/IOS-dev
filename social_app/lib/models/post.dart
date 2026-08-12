import '../core/base/base_model.dart';

/// Immutable post model.
///
/// Represents a single feed post with image, caption, and engagement counts.
class Post extends BaseModel {
  final String _id;
  final String _userId;
  final String _imageUrl;
  final String _caption;
  final int _likesCount;
  final int _commentsCount;
  final DateTime _createdAt;

  // ── Named constructor ───────────────────────────────────────────────────

  Post({
    required String id,
    required String userId,
    required String imageUrl,
    String caption = '',
    int likesCount = 0,
    int commentsCount = 0,
    required DateTime createdAt,
  })  : _id = id,
        _userId = userId,
        _imageUrl = imageUrl,
        _caption = caption,
        _likesCount = likesCount,
        _commentsCount = commentsCount,
        _createdAt = createdAt;

  // ── Factory from JSON ───────────────────────────────────────────────────

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      caption: json['caption'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // ── Getters ─────────────────────────────────────────────────────────────

  @override
  String get id => _id;
  String get userId => _userId;
  String get imageUrl => _imageUrl;
  String get caption => _caption;
  int get likesCount => _likesCount;
  int get commentsCount => _commentsCount;
  DateTime get createdAt => _createdAt;

  // ── Serialisation ───────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'user_id': _userId,
      'image_url': _imageUrl,
      'caption': _caption,
      'likes_count': _likesCount,
      'comments_count': _commentsCount,
      'created_at': _createdAt.toIso8601String(),
    };
  }

  // ── Copy-with ───────────────────────────────────────────────────────────

  Post copyWith({
    String? imageUrl,
    String? caption,
    int? likesCount,
    int? commentsCount,
  }) {
    return Post(
      id: _id,
      userId: _userId,
      imageUrl: imageUrl ?? _imageUrl,
      caption: caption ?? _caption,
      likesCount: likesCount ?? _likesCount,
      commentsCount: commentsCount ?? _commentsCount,
      createdAt: _createdAt,
    );
  }
}
