import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_auth_service.dart';
import '../../services/supabase_feed_service.dart';
import '../../services/supabase_comment_service.dart';
import '../../services/supabase_chat_service.dart';

/// Provides the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides the Supabase Auth Service
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthService(client);
});

/// Provides the Supabase Feed Service
final supabaseFeedServiceProvider = Provider<SupabaseFeedService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseFeedService(client);
});

/// Provides the Supabase Comment Service
final supabaseCommentServiceProvider = Provider<SupabaseCommentService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseCommentService(client);
});

/// Provides the Supabase Chat Service
final supabaseChatServiceProvider = Provider<SupabaseChatService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseChatService(client);
});
