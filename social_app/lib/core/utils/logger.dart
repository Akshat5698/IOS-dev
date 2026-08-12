import 'dart:developer' as developer;

/// Lightweight application logger.
///
/// Uses [developer.log] under the hood so messages appear in the Dart
/// DevTools console with proper severity levels.
class AppLogger {
  static const String _name = 'SocialApp';

  // ── Public API ──────────────────────────────────────────────────────────

  /// Log a debug-level message.
  static void debug(String message, {String? tag}) {
    _log(message, level: 0, tag: tag);
  }

  /// Log an informational message.
  static void info(String message, {String? tag}) {
    _log(message, level: 800, tag: tag);
  }

  /// Log a warning.
  static void warning(String message, {String? tag}) {
    _log(message, level: 900, tag: tag);
  }

  /// Log an error, optionally with an [error] object and [stackTrace].
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      message,
      level: 1000,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ── Internals ───────────────────────────────────────────────────────────

  static void _log(
    String message, {
    required int level,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _name,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Prevent instantiation.
  AppLogger._();
}
