import '../core/base/base_repository.dart';
import '../core/base/base_service.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../core/mock/mock_database.dart';

class MockMessageRepository extends BaseRepository<Message> {
  final MockDatabase _db = MockDatabase.instance;

  @override
  String get tableName => 'messages';

  @override
  Message fromJson(Map<String, dynamic> json) => Message.fromJson(json);

  @override
  Future<List<Message>> fetchAll({String orderBy = 'created_at', bool ascending = false, int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var sorted = List<Message>.from(_db.messages);
    sorted.sort((a, b) => ascending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt));
    if (limit != null && sorted.length > limit) sorted = sorted.sublist(0, limit);
    return sorted;
  }

  @override
  Future<Message?> fetchById(String id) async {
    try {
      return _db.messages.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Message>> fetchWhere(Map<String, dynamic> filters) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _db.messages; // Basic mock
  }

  @override
  Future<Message> create(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: data['sender_id'],
      receiverId: data['receiver_id'],
      content: data['content'],
      createdAt: DateTime.now(),
    );
    _db.messages.add(newMsg);
    return newMsg;
  }

  @override
  Future<Message> update(String id, Map<String, dynamic> data) async {
    final index = _db.messages.indexWhere((m) => m.id == id);
    if (index == -1) throw Exception('Not found');
    final m = _db.messages[index];
    final updated = m.copyWith(
      isRead: data['is_read'] as bool?,
    );
    _db.messages[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    _db.messages.removeWhere((m) => m.id == id);
  }
}

/// Domain service for direct-message / chat operations.
class ChatService extends BaseService<Message> {
  final MockMessageRepository _repository;

  ChatService({MockMessageRepository? repository})
      : _repository = repository ?? MockMessageRepository();

  @override
  BaseRepository<Message> get repository => _repository;

  // ── Domain-specific helpers ─────────────────────────────────────────────

  Future<List<Conversation>> fetchConversations() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockDatabase.instance.conversations;
  }

  Future<List<Message>> fetchConversation(String currentUserId, String otherUserId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allMessages = MockDatabase.instance.messages;
    return allMessages.where((m) {
      return (m.senderId == currentUserId && m.receiverId == otherUserId) ||
             (m.senderId == otherUserId && m.receiverId == currentUserId);
    }).toList();
  }

  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) {
    return create({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  Future<Message> markAsRead(String messageId) {
    return update(messageId, {'is_read': true});
  }
}
