import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../core/base/base_repository.dart';
import '../core/base/base_service.dart';
import '../models/post.dart';
// We'll need this for the legacy fetchComments if any, or we just remove it.

class SupabasePostRepository extends BaseRepository<Post> {
  final supabase.SupabaseClient _client;

  SupabasePostRepository(this._client);

  @override
  String get tableName => 'posts';

  @override
  Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['media_url'] as String,
      caption: json['caption'] as String? ?? '',
      likesCount: json['like_count'] as int? ?? 0,
      commentsCount: json['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Future<List<Post>> fetchAll({String orderBy = 'created_at', bool ascending = false, int? limit}) async {
    // We join the profiles table to get user details
    final query = _client.from(tableName).select('*, profiles(*)').order(orderBy, ascending: ascending);
    if (limit != null) {
      final response = await query.limit(limit);
      return response.map((json) => fromJson(json)).toList();
    } else {
      final response = await query;
      return response.map((json) => fromJson(json)).toList();
    }
  }

  @override
  Future<Post?> fetchById(String id) async {
    try {
      final response = await _client.from(tableName).select('*, profiles(*)').eq('id', id).maybeSingle();
      if (response == null) return null;
      return fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Post>> fetchWhere(Map<String, dynamic> filters) async {
    var query = _client.from(tableName).select('*, profiles(*)');
    for (final entry in filters.entries) {
      query = query.eq(entry.key, entry.value);
    }
    final response = await query.order('created_at', ascending: false);
    return response.map((json) => fromJson(json)).toList();
  }

  @override
  Future<Post> create(Map<String, dynamic> data) async {
    final response = await _client
        .from(tableName)
        .insert(data)
        .select()
        .single();
    return fromJson(response);
  }

  @override
  Future<Post> update(String id, Map<String, dynamic> data) async {
    final response = await _client
        .from(tableName)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return fromJson(response);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }
}

class SupabaseFeedService extends BaseService<Post> {
  final supabase.SupabaseClient _client;
  final SupabasePostRepository _repository;

  SupabaseFeedService(this._client)
    : _repository = SupabasePostRepository(_client);

  @override
  BaseRepository<Post> get repository => _repository;

  Future<List<Post>> fetchFeed({int page = 0}) {
    // Basic pagination could be added using range queries
    return _repository.fetchAll();
  }

  Future<List<Post>> fetchPostsByUser(String userId) {
    return _repository.fetchWhere({'user_id': userId});
  }

  /// Create a post with an image upload
  Future<Post> createPost({
    required String userId,
    required Uint8List imageBytes, // Web-friendly upload format
    required String fileExtension,
    String caption = '',
  }) async {
    // 1. Upload to storage
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final filePath = '$userId/$fileName';

    await _client.storage
        .from('posts')
        .uploadBinary(
          filePath,
          imageBytes,
          fileOptions: supabase.FileOptions(
            contentType: 'image/$fileExtension',
          ),
        );

    final publicUrl = _client.storage.from('posts').getPublicUrl(filePath);

    // 2. Create post row
    return _repository.create({
      'user_id': userId,
      'media_url': publicUrl,
      'caption': caption,
    });
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    // We increment or decrement naively on the client.
    // In a production app, we'd use a postgres function (RPC) or a dedicated likes table.
    final post = await _repository.fetchById(postId);
    if (post != null) {
      final newLikeCount = isLiked ? post.likesCount - 1 : post.likesCount + 1;
      await _repository.update(postId, {
        'like_count': newLikeCount < 0 ? 0 : newLikeCount,
      });
    }
  }
}
