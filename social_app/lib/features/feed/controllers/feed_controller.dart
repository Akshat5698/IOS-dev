import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_providers.dart';
import '../../../services/supabase_feed_service.dart';
import '../../../models/post.dart';

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
  final SupabaseFeedService _feedService;

  FeedController({required SupabaseFeedService feedService})
      : _feedService = feedService,
        super(const FeedState());

  /// Load the feed (first page).
  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final posts = await _feedService.fetchFeed();
      if (mounted) {
        state = state.copyWith(isLoading: false, posts: posts);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  /// Refresh the feed (pull-to-refresh).
  Future<void> refresh() => loadFeed();

  /// Create a new post and prepend it to the feed.
  Future<void> createPost({
    required String userId,
    required Uint8List imageBytes,
    required String fileExtension,
    String caption = '',
  }) async {
    try {
      final post = await _feedService.createPost(
        userId: userId,
        imageBytes: imageBytes,
        fileExtension: fileExtension,
        caption: caption,
      );
      if (mounted) {
        state = state.copyWith(posts: [post, ...state.posts]);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(errorMessage: e.toString());
      }
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
  return FeedController(feedService: ref.watch(supabaseFeedServiceProvider));
});
