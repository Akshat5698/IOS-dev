import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl != null && supabaseAnonKey != null && supabaseUrl.startsWith('http')) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } else {
      debugPrint('WARNING: Invalid or missing SUPABASE_URL / SUPABASE_ANON_KEY in .env');
    }
  } catch (e) {
    debugPrint('WARNING: Could not load .env file or initialize Supabase: $e');
  }

  // ── Launch app ────────────────────────────────────────────────────────
  runApp(const ProviderScope(child: SocialApp()));
}
