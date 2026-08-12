/// Application-wide constants.
///
/// All magic strings and numbers live here to keep the rest of the codebase
/// free of hard-coded values.
class AppConstants {
  // ── Supabase table names ────────────────────────────────────────────────
  static const String profilesTable = 'profiles';
  static const String postsTable = 'posts';
  static const String messagesTable = 'messages';
  static const String notificationsTable = 'notifications';

  // ── Pagination ──────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int chatPageSize = 50;

  // ── Date / time ─────────────────────────────────────────────────────────
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';

  // ── Storage buckets ─────────────────────────────────────────────────────
  static const String avatarsBucket = 'avatars';
  static const String postImagesBucket = 'post-images';

  // ── Misc ────────────────────────────────────────────────────────────────
  static const int maxCaptionLength = 2200;
  static const int maxBioLength = 150;
  static const int maxUsernameLength = 30;

  // Prevent instantiation.
  AppConstants._();
}
