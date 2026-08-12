import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_view.dart';
import '../controllers/chat_controller.dart';
import 'chat_screen.dart';

/// Screen showing a list of recent conversations.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authControllerProvider).user;
    final chatListAsync = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser?.username ?? 'Messages', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {},
          ),
        ],
      ),
      body: chatListAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(chatListProvider),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No conversations yet', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final otherUser = conv.otherUser;
              if (otherUser == null || currentUser == null) return const SizedBox.shrink();

              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(otherUser.avatarUrl ?? 'https://placehold.co/100x100.png'),
                ),
                title: Text(otherUser.username, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  conv.lastMessage?.content ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                trailing: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        currentUserId: currentUser.id,
                        otherUserId: otherUser.id,
                        otherUsername: otherUser.username,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
