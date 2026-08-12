import '../core/base/base_model.dart';

/// Immutable direct-message model.
class Message extends BaseModel {
  final String _id;
  final String _senderId;
  final String _conversationId;
  final String _content;
  final bool _isRead;
  final DateTime _createdAt;

  // ── Named constructor ───────────────────────────────────────────────────

  Message({
    required String id,
    required String senderId,
    required String conversationId,
    required String content,
    bool isRead = false,
    required DateTime createdAt,
  })  : _id = id,
        _senderId = senderId,
        _conversationId = conversationId,
        _content = content,
        _isRead = isRead,
        _createdAt = createdAt;

  // ── Factory from JSON ───────────────────────────────────────────────────

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      conversationId: json['conversation_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // ── Getters ─────────────────────────────────────────────────────────────

  @override
  String get id => _id;
  String get senderId => _senderId;
  String get conversationId => _conversationId;
  String get content => _content;
  bool get isRead => _isRead;
  DateTime get createdAt => _createdAt;

  // ── Serialisation ───────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'sender_id': _senderId,
      'conversation_id': _conversationId,
      'content': _content,
      'is_read': _isRead,
      'created_at': _createdAt.toIso8601String(),
    };
  }

  // ── Copy-with ───────────────────────────────────────────────────────────

  Message copyWith({
    String? content,
    bool? isRead,
  }) {
    return Message(
      id: _id,
      senderId: _senderId,
      conversationId: _conversationId,
      content: content ?? _content,
      isRead: isRead ?? _isRead,
      createdAt: _createdAt,
    );
  }
}
