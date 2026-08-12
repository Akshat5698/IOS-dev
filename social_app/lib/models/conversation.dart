import '../core/base/base_model.dart';
import 'message.dart';
import 'user.dart';

/// Immutable conversation model.
class Conversation extends BaseModel {
  final String _id;
  final List<String> _participantIds;
  final Message? _lastMessage;
  final DateTime _updatedAt;
  
  // Transient property (mock data only) for UI convenience
  final User? _otherUser;

  // ── Named constructor ───────────────────────────────────────────────────

  Conversation({
    required String id,
    required List<String> participantIds,
    Message? lastMessage,
    required DateTime updatedAt,
    User? otherUser,
  })  : _id = id,
        _participantIds = participantIds,
        _lastMessage = lastMessage,
        _updatedAt = updatedAt,
        _otherUser = otherUser;

  // ── Factory from JSON ───────────────────────────────────────────────────

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      participantIds: List<String>.from(json['participant_ids'] as List),
      lastMessage: json['last_message'] != null 
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>) 
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // ── Getters ─────────────────────────────────────────────────────────────

  @override
  String get id => _id;
  List<String> get participantIds => _participantIds;
  Message? get lastMessage => _lastMessage;
  DateTime get updatedAt => _updatedAt;
  User? get otherUser => _otherUser;

  // ── Serialisation ───────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'participant_ids': _participantIds,
      'last_message': _lastMessage?.toJson(),
      'updated_at': _updatedAt.toIso8601String(),
    };
  }

  // ── Copy-with ───────────────────────────────────────────────────────────

  Conversation copyWith({
    List<String>? participantIds,
    Message? lastMessage,
    DateTime? updatedAt,
    User? otherUser,
  }) {
    return Conversation(
      id: _id,
      participantIds: participantIds ?? _participantIds,
      lastMessage: lastMessage ?? _lastMessage,
      updatedAt: updatedAt ?? _updatedAt,
      otherUser: otherUser ?? _otherUser,
    );
  }
}
