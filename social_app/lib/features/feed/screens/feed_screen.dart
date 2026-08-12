import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/mock/mock_database.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../widgets/error_view.dart';
import '../../../widgets/loading_indicator.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../controllers/feed_controller.dart';
import '../../../models/post.dart';
import '../../../models/user.dart';

/// Main feed screen matching an Instagram-style layout.
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  // Local state for tracking liked posts in UI before server sync
  final Set<String> _likedPostIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(feedControllerProvider.notifier).loadFeed(),
    );
  }

  void _toggleLike(Post post) {
    setState(() {
      if (_likedPostIds.contains(post.id)) {
        _likedPostIds.remove(post.id);
        ref.read(supabaseFeedServiceProvider).toggleLike(post.id, true);
      } else {
        _likedPostIds.add(post.id);
        ref.read(supabaseFeedServiceProvider).toggleLike(post.id, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instagram',
          style: GoogleFonts.grandHotel(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(feedState, theme),
    );
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

    return RefreshIndicator(
      onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // Stories Section
          SliverToBoxAdapter(
            child: _buildStoriesBar(theme),
          ),
          const SliverToBoxAdapter(
            child: Divider(height: 1, thickness: 0.3),
          ),
          // Feed Section
          if (feedState.posts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No posts yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPost(feedState.posts[index], theme),
                childCount: feedState.posts.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoriesBar(ThemeData theme) {
    final users = MockDatabase.instance.otherUsers;
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildStoryItem(
              theme,
              user: MockDatabase.instance.currentUser,
              isAddStory: true,
            );
          }
          return _buildStoryItem(
            theme,
            user: users[index - 1],
          );
        },
      ),
    );
  }

  Widget _buildStoryItem(ThemeData theme, {required User user, bool isAddStory = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isAddStory ? null : const LinearGradient(
                    colors: [Colors.purple, Colors.orange, Colors.red],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(user.avatarUrl ?? 'https://placehold.co/100'),
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
              if (isAddStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                    ),
                    child: const Icon(Icons.add, size: 18, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isAddStory ? 'Your story' : user.username,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPost(Post post, ThemeData theme) {
    final user = post.author;
    final isLiked = _likedPostIds.contains(post.id);
    final displayLikes = post.likesCount + (isLiked ? 1 : 0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://placehold.co/100'),
              ),
              const SizedBox(width: 10),
              Text(
                user?.username ?? post.userId,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 14, color: Colors.blue),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(60, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Follow'),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_horiz),
            ],
          ),
        ),

        // Post image
        AspectRatio(
          aspectRatio: 1, // 1:1 Instagram style crop
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : null,
                  size: 28,
                ),
                onPressed: () => _toggleLike(post),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 26),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined, size: 26),
                onPressed: () {},
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border, size: 28),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Likes count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '$displayLikes likes',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),

        // Caption
        if (post.caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: '${user?.username ?? post.userId} ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: post.caption),
                ],
              ),
            ),
          ),

        // Comments shortcut
        if (post.commentsCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Text(
              'View all ${post.commentsCount} comments',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),

        const SizedBox(height: 12),
      ],
    );
  }
}
