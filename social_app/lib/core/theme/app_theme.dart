import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme definition.
///
/// Provides static [light] and [dark] getters that return fully configured
/// [ThemeData] objects.  The palette follows an Instagram-inspired aesthetic:
/// generous whitespace, subtle borders, neutral tones with a single accent.
class AppTheme {
  // ── Palette ─────────────────────────────────────────────────────────────
  // Accent — Instagram blue
  static const Color _accent = Color(0xFF0095F6);
  static const Color _accentDark = Color(0xFF4DB5F9);

  // Light surfaces
  static const Color _lightBackground = Color(0xFFFAFAFA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFDBDBDB);
  static const Color _lightTextPrimary = Color(0xFF262626);
  static const Color _lightTextSecondary = Color(0xFF8E8E8E);

  // Dark surfaces
  static const Color _darkBackground = Color(0xFF000000);
  static const Color _darkSurface = Color(0xFF121212);
  static const Color _darkBorder = Color(0xFF363636);
  static const Color _darkTextPrimary = Color(0xFFF5F5F5);
  static const Color _darkTextSecondary = Color(0xFFA8A8A8);

  // Semantic
  static const Color _error = Color(0xFFED4956);
  static const Color _success = Color(0xFF58C322);

  // ── Light Theme ─────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: _accent,
        secondary: _accent,
        surface: _lightSurface,
        error: _error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: _lightSurface,
        foregroundColor: _lightTextPrimary,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _lightTextPrimary,
        ),
        iconTheme: const IconThemeData(color: _lightTextPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightBorder,
        thickness: 0.5,
        space: 0,
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _lightBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: _lightTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accent,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _lightTextPrimary,
        unselectedItemColor: _lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: _buildTextTheme(base.textTheme, _lightTextPrimary),
      iconTheme: const IconThemeData(color: _lightTextPrimary, size: 24),
    );
  }

  // ── Dark Theme ──────────────────────────────────────────────────────────

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: _accentDark,
        secondary: _accentDark,
        surface: _darkSurface,
        error: _error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: _darkBackground,
        foregroundColor: _darkTextPrimary,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _darkTextPrimary,
        ),
        iconTheme: const IconThemeData(color: _darkTextPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: _darkBorder,
        thickness: 0.5,
        space: 0,
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _darkBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentDark, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: _darkTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentDark,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkBackground,
        selectedItemColor: _darkTextPrimary,
        unselectedItemColor: _darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: _buildTextTheme(base.textTheme, _darkTextPrimary),
      iconTheme: const IconThemeData(color: _darkTextPrimary, size: 24),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return GoogleFonts.interTextTheme(base).apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
  }

  /// Returns the success color for positive feedback.
  static Color get successColor => _success;

  /// Returns the error color for destructive / negative feedback.
  static Color get errorColor => _error;

  // Prevent instantiation.
  AppTheme._();
}
