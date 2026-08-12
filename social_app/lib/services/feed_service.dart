import '../core/base/base_repository.dart';
import '../core/base/base_service.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../core/mock/mock_database.dart';

class MockPostRepository extends BaseRepository<Post> {
  final MockDatabase _db = MockDatabase.instance;

  @override
  String get tableName => 'posts';

  @override
  Post fromJson(Map<String, dynamic> json) => Post.fromJson(json);

  @override
  Future<List<Post>> fetchAll({String orderBy = 'created_at', bool ascending = false, int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var sorted = List<Post>.from(_db.posts);
    sorted.sort((a, b) => ascending ? a.createdAt.compareTo(b.createdAt) : b.createdAt.compareTo(a.createdAt));
    if (limit != null && sorted.length > limit) sorted = sorted.sublist(0, limit);
    return sorted;
  }

  @override
  Future<Post?> fetchById(String id) async {
    try {
      return _db.posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Post>> fetchWhere(Map<String, dynamic> filters) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _db.posts.where((p) {
      bool matches = true;
      if (filters.containsKey('user_id') && p.userId != filters['user_id']) matches = false;
      return matches;
    }).toList();
  }

  @override
  Future<Post> create(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: data['user_id'],
      imageUrl: data['image_url'],
      caption: data['caption'] ?? '',
      createdAt: DateTime.now(),
    );
    _db.posts.insert(0, newPost);
    return newPost;
  }

  @override
  Future<Post> update(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _db.posts.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('Not found');
    final p = _db.posts[index];
    final updated = p.copyWith(
      caption: data['caption'] as String?,
      likesCount: data['likes_count'] as int?,
      commentsCount: data['comments_count'] as int?,
    );
    _db.posts[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    _db.posts.removeWhere((p) => p.id == id);
  }
}

/// Domain service for feed / post operations.
class FeedService extends BaseService<Post> {
  final MockPostRepository _repository;

  FeedService({MockPostRepository? repository})
      : _repository = repository ?? MockPostRepository();

  @override
  BaseRepository<Post> get repository => _repository;

  // ── Domain-specific helpers ─────────────────────────────────────────────

  Future<List<Post>> fetchFeed({int page = 0}) {
    return _repository.fetchAll();
  }

  Future<List<Post>> fetchPostsByUser(String userId) {
    return _repository.fetchWhere({'user_id': userId});
  }

  Future<Post> createPost({
    required String userId,
    required String imageUrl,
    String caption = '',
  }) {
    return create({
      'user_id': userId,
      'image_url': imageUrl,
      'caption': caption,
    });
  }

  // Comments
  Future<List<Comment>> fetchComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockDatabase.instance.comments.where((c) => c.postId == postId).toList();
  }

  Future<Comment> addComment(String postId, String userId, String text) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      userId: userId,
      text: text,
      createdAt: DateTime.now(),
    );
    MockDatabase.instance.comments.add(comment);
    
    // update comment count locally
    final post = await _repository.fetchById(postId);
    if (post != null) {
      await update(postId, {'comments_count': post.commentsCount + 1});
    }
    return comment;
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockDatabase.instance.comments.removeWhere((c) => c.id == commentId);
    final post = await _repository.fetchById(postId);
    if (post != null) {
      await update(postId, {'comments_count': post.commentsCount > 0 ? post.commentsCount - 1 : 0});
    }
  }

  // Like toggle
  Future<void> toggleLike(String postId, bool isLiked) async {
    final post = await _repository.fetchById(postId);
    if (post != null) {
      await update(postId, {
        'likes_count': isLiked ? post.likesCount - 1 : post.likesCount + 1
      });
    }
  }
}
