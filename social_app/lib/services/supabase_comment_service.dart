import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../core/base/base_repository.dart';
import '../core/base/base_service.dart';
import '../models/comment.dart';
import '../models/user.dart'; // To attach the user object
import 'supabase_auth_service.dart'; // To fetch the user

class SupabaseCommentRepository extends BaseRepository<Comment> {
  final supabase.SupabaseClient _client;

  SupabaseCommentRepository(this._client);

  @override
  String get tableName => 'comments';

  @override
  Comment fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      text: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Future<List<Comment>> fetchAll({String orderBy = 'created_at', bool ascending = false, int? limit}) async {
    if (limit != null) {
      final response = await _client.from(tableName).select().order(orderBy, ascending: ascending).limit(limit);
      return response.map((json) => fromJson(json)).toList();
    } else {
      final response = await _client.from(tableName).select().order(orderBy, ascending: ascending);
      return response.map((json) => fromJson(json)).toList();
    }
  }

  @override
  Future<Comment?> fetchById(String id) async {
    try {
      final response = await _client.from(tableName).select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Comment>> fetchWhere(Map<String, dynamic> filters) async {
    var query = _client.from(tableName).select();
    for (final entry in filters.entries) {
      query = query.eq(entry.key, entry.value);
    }
    final response = await query.order('created_at', ascending: true);
    return response.map((json) => fromJson(json)).toList();
  }

  @override
  Future<Comment> create(Map<String, dynamic> data) async {
    final response = await _client.from(tableName).insert(data).select().single();
    return fromJson(response);
  }

  @override
  Future<Comment> update(String id, Map<String, dynamic> data) async {
    final response = await _client.from(tableName).update(data).eq('id', id).select().single();
    return fromJson(response);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(tableName).delete().eq('id', id);
  }
}

class SupabaseCommentService extends BaseService<Comment> {
  final supabase.SupabaseClient _client;
  final SupabaseCommentRepository _repository;
  final SupabaseUserRepository _userRepository;

  SupabaseCommentService(this._client) 
    : _repository = SupabaseCommentRepository(_client),
      _userRepository = SupabaseUserRepository(_client);

  @override
  BaseRepository<Comment> get repository => _repository;

  Future<List<Comment>> fetchCommentsForPost(String postId) async {
    final comments = await _repository.fetchWhere({'post_id': postId});
    // We need to attach the User objects since the old UI expects it.
    // In a real app we'd do a SQL JOIN, but doing it in code here for simplicity
    // given the architecture.
    final userIds = comments.map((c) => c.userId).toSet().toList();
    if (userIds.isEmpty) return comments;
    
    final usersResponse = await _client.from('profiles').select().inFilter('id', userIds);
    final users = usersResponse.map((json) => _userRepository.fromJson(json)).toList();
    
    final userMap = {for (var u in users) u.id: u};
    
    return comments.map((c) {
      final user = userMap[c.userId];
      return c.copyWith(user: user);
    }).toList();
  }

  Future<Comment> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    var comment = await _repository.create({
      'post_id': postId,
      'user_id': userId,
      'content': content,
    });
    
    final user = await _userRepository.fetchById(userId);
    return comment.copyWith(user: user);
  }
}
