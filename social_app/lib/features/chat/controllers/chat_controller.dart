import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/message.dart';
import '../../../models/conversation.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../services/supabase_chat_service.dart';
import '../../auth/controllers/auth_controller.dart';

// ── State ─────────────────────────────────────────────────────────────────

class ChatState {
  final bool isLoading;
  final List<Message> messages;
  final String? errorMessage;
  final String? conversationId;

  const ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.errorMessage,
    this.conversationId,
  });

  ChatState copyWith({
    bool? isLoading,
    List<Message>? messages,
    String? errorMessage,
    String? conversationId,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────

class ChatController extends StateNotifier<ChatState> {
  final SupabaseChatService _chatService;
  RealtimeChannel? _subscription;

  ChatController({required SupabaseChatService chatService})
      : _chatService = chatService,
        super(const ChatState());

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  /// Load a conversation between two users.
  Future<void> loadConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final messages = await _chatService.fetchConversation(
        currentUserId,
        otherUserId,
      );
      
      String? convId;
      if (messages.isNotEmpty) {
        convId = messages.first.conversationId;
      }
      
      if (mounted) {
        state = state.copyWith(isLoading: false, messages: messages, conversationId: convId);
      }
      
      // Subscribe to real-time changes
      if (convId != null) {
        _subscribeToConversation(convId);
      }
      
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  void _subscribeToConversation(String conversationId) {
    _subscription?.unsubscribe();
    _subscription = _chatService.subscribeToConversation(conversationId, (newMessage) {
      if (!mounted) return;
      // Prevent duplicate messages (since sendMessage adds it optimistically)
      if (!state.messages.any((m) => m.id == newMessage.id)) {
        state = state.copyWith(messages: [...state.messages, newMessage]);
      }
    });
  }

  /// Send a message and append it to the conversation.
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      final message = await _chatService.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
      
      if (mounted) {
        state = state.copyWith(messages: [...state.messages, message]);
        if (state.conversationId == null) {
          state = state.copyWith(conversationId: message.conversationId);
          _subscribeToConversation(message.conversationId);
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final chatListProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final chatService = ref.watch(supabaseChatServiceProvider);
  final currentUser = ref.watch(authControllerProvider).user;
  
  if (currentUser == null) return [];
  
  return chatService.fetchConversations(currentUser.id);
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(chatService: ref.watch(supabaseChatServiceProvider));
});
