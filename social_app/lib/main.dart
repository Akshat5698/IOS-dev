import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Launch app ────────────────────────────────────────────────────────
  runApp(const ProviderScope(child: SocialApp()));
}
