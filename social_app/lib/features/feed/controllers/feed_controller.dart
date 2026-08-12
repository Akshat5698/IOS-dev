import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/post.dart';
import '../../../services/feed_service.dart';

// ── State ─────────────────────────────────────────────────────────────────

class FeedState {
  final bool isLoading;
  final List<Post> posts;
  final String? errorMessage;

  const FeedState({
    this.isLoading = false,
    this.posts = const [],
    this.errorMessage,
  });

  FeedState copyWith({
    bool? isLoading,
    List<Post>? posts,
    String? errorMessage,
  }) {
    return FeedState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
    );
  }
}

// ── Controller ────────────────────────────────────────────────────────────

class FeedController extends StateNotifier<FeedState> {
  final FeedService _feedService;

  FeedController({FeedService? feedService})
      : _feedService = feedService ?? FeedService(),
        super(const FeedState());

  /// Load the feed (first page).
  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final posts = await _feedService.fetchFeed();
      state = state.copyWith(isLoading: false, posts: posts);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Refresh the feed (pull-to-refresh).
  Future<void> refresh() => loadFeed();

  /// Create a new post and prepend it to the feed.
  Future<void> createPost({
    required String userId,
    required String imageUrl,
    String caption = '',
  }) async {
    try {
      final post = await _feedService.createPost(
        userId: userId,
        imageUrl: imageUrl,
        caption: caption,
      );
      state = state.copyWith(posts: [post, ...state.posts]);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final feedServiceProvider = Provider<FeedService>((ref) => FeedService());

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
  return FeedController(feedService: ref.watch(feedServiceProvider));
});
