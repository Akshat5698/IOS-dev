import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_database.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/loading_indicator.dart';
import '../controllers/feed_controller.dart';

/// Main feed screen displaying a scrollable list of posts.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Load the feed when the screen first mounts.
    Future.microtask(
      () => ref.read(feedControllerProvider.notifier).loadFeed(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Social',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              // TODO: Navigate to create-post screen.
            },
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () {
              // TODO: Navigate to chat list.
            },
          ),
        ],
      ),
      body: _buildBody(feedState, theme),
    );
  }

  String _getUserName(String userId) {
    return MockDatabase.instance.getUser(userId)?.username ?? userId;
  }

  Widget _buildBody(FeedState feedState, ThemeData theme) {
    if (feedState.isLoading && feedState.posts.isEmpty) {
      return const LoadingIndicator();
    }

    if (feedState.errorMessage != null && feedState.posts.isEmpty) {
      return ErrorView(
        message: feedState.errorMessage!,
        onRetry: () => ref.read(feedControllerProvider.notifier).loadFeed(),
      );
    }

    if (feedState.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined,
                size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
      child: ListView.separated(
        itemCount: feedState.posts.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final post = feedState.posts[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor:
                          theme.colorScheme.onSurface.withOpacity(0.1),
                      child: const Icon(Icons.person, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _getUserName(post.userId),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Post image
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.colorScheme.onSurface.withOpacity(0.05),
                    child: const Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
              ),

              // Action bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      onPressed: () {},
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Likes count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${post.likesCount} likes',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),

              // Caption
              if (post.caption.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '${post.userId} ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}
