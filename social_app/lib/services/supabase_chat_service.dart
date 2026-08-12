import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../core/base/base_repository.dart';
import '../core/base/base_service.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../models/user.dart';

class SupabaseMessageRepository extends BaseRepository<Message> {
  final supabase.SupabaseClient _client;

  SupabaseMessageRepository(this._client);

  @override
  String get tableName => 'messages';

  @override
  Message fromJson(Map<String, dynamic> json) => Message.fromJson(json);

  @override
  Future<List<Message>> fetchAll({String orderBy = 'created_at', bool ascending = false, int? limit}) async {
    final query = _client.from(tableName).select().order(orderBy, ascending: ascending);
    if (limit != null) {
      final response = await query.limit(limit);
      return response.map((json) => fromJson(json)).toList();
    } else {
      final response = await query;
      return response.map((json) => fromJson(json)).toList();
    }
  }

  @override
  Future<Message?> fetchById(String id) async {
    try {
      final response = await _client.from(tableName).select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Message>> fetchWhere(Map<String, dynamic> filters) async {
    var query = _client.from(tableName).select();
    for (final entry in filters.entries) {
      query = query.eq(entry.key, entry.value);
    }
    final response = await query.order('created_at', ascending: true);
    return response.map((json) => fromJson(json)).toList();
  }

  @override
  Future<Message> create(Map<String, dynamic> data) async {
    final response = await _client.from(tableName).insert(data).select().single();
    return fromJson(response);
  }

  @override
  Future<Message> update(String id, Map<String, dynamic> data) async {
    final response = await _client.from(tableName).update(data).eq('id', id).select().single();
    return fromJson(response);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }
}

class SupabaseChatService extends BaseService<Message> {
  final supabase.SupabaseClient _client;
  final SupabaseMessageRepository _repository;

  SupabaseChatService(this._client) : _repository = SupabaseMessageRepository(_client);

  @override
  BaseRepository<Message> get repository => _repository;

  Future<List<Conversation>> fetchConversations(String currentUserId) async {
    // We need to fetch conversations where currentUserId is a participant
    // For simplicity, we can fetch all participant records for this user, then fetch the conversations and the *other* participant
    final participantsRes = await _client.from('conversation_participants').select('conversation_id').eq('user_id', currentUserId);
    final conversationIds = participantsRes.map((e) => e['conversation_id'] as String).toList();
    
    if (conversationIds.isEmpty) return [];

    final convsRes = await _client.from('conversations').select('*, conversation_participants!inner(user_id, profiles(*)), messages!left(*)').inFilter('id', conversationIds).order('updated_at', ascending: false);

    return convsRes.map((convJson) {
      final participants = List<Map<String, dynamic>>.from(convJson['conversation_participants']);
      final participantIds = participants.map((p) => p['user_id'] as String).toList();
      
      // Find the other user
      final otherParticipant = participants.firstWhere((p) => p['user_id'] != currentUserId, orElse: () => participants.first);
      final otherUser = User.fromJson(otherParticipant['profiles']);
      
      // Get last message
      final messages = List<Map<String, dynamic>>.from(convJson['messages'] ?? []);
      messages.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
      final lastMessage = messages.isNotEmpty ? Message.fromJson(messages.first) : null;
      
      return Conversation(
        id: convJson['id'] as String,
        participantIds: participantIds,
        updatedAt: DateTime.parse(convJson['updated_at']),
        otherUser: otherUser,
        lastMessage: lastMessage,
      );
    }).toList();
  }

  Future<String> _getOrCreateConversation(String user1, String user2) async {
    // Find existing conversation
    // Querying intersection of conversations can be complex in REST, doing it in two queries
    final p1 = await _client.from('conversation_participants').select('conversation_id').eq('user_id', user1);
    final p2 = await _client.from('conversation_participants').select('conversation_id').eq('user_id', user2);
    
    final set1 = p1.map((e) => e['conversation_id'] as String).toSet();
    final set2 = p2.map((e) => e['conversation_id'] as String).toSet();
    
    final intersection = set1.intersection(set2);
    if (intersection.isNotEmpty) {
      return intersection.first;
    }
    
    // Create new conversation
    final newConv = await _client.from('conversations').insert({}).select().single();
    final convId = newConv['id'] as String;
    
    await _client.from('conversation_participants').insert([
      {'conversation_id': convId, 'user_id': user1},
      {'conversation_id': convId, 'user_id': user2},
    ]);
    
    return convId;
  }

  Future<List<Message>> fetchConversation(String currentUserId, String otherUserId) async {
    final convId = await _getOrCreateConversation(currentUserId, otherUserId);
    return await _repository.fetchWhere({'conversation_id': convId});
  }

  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final convId = await _getOrCreateConversation(senderId, receiverId);
    
    // Update conversation updated_at
    await _client.from('conversations').update({
      'updated_at': DateTime.now().toIso8601String()
    }).eq('id', convId);
    
    return await create({
      'conversation_id': convId,
      'sender_id': senderId,
      'content': content,
    });
  }

  Future<Message> markAsRead(String messageId) {
    return update(messageId, {'is_read': true});
  }

  // Realtime subscription for a conversation
  supabase.RealtimeChannel subscribeToConversation(String conversationId, void Function(Message) onNewMessage) {
    return _client.channel('public:messages:conversation_id=$conversationId')
      .onPostgresChanges(
        event: supabase.PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: supabase.PostgresChangeFilter(
          type: supabase.PostgresChangeFilterType.eq,
          column: 'conversation_id',
          value: conversationId,
        ),
        callback: (payload) {
          final newRecord = payload.newRecord;
          if (newRecord != null) {
            onNewMessage(Message.fromJson(newRecord));
          }
        },
      )
      .subscribe();
  }
}
