import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/message.dart';
import '../../../services/chat_service.dart';

// ── State ─────────────────────────────────────────────────────────────────

class ChatState {
  final bool isLoading;
  final List<Message> messages;
  final String? errorMessage;

  const ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    bool? isLoading,
    List<Message>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────

class ChatController extends StateNotifier<ChatState> {
  final ChatService _chatService;

  ChatController({ChatService? chatService})
      : _chatService = chatService ?? ChatService(),
        super(const ChatState());

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
      state = state.copyWith(isLoading: false, messages: messages);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
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
      state = state.copyWith(messages: [...state.messages, message]);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(chatService: ref.watch(chatServiceProvider));
});
