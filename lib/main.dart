import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/editor/data/draft_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Initialize date formatting ──
  await _initializeLocales();

  // ── Load persisted preferences ──
  final prefs = await _loadPrefs();

  // ── System UI styling ──
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const AssignX(),
    ),
  );
}

Future<void> _initializeLocales() async {
  try {
    await initializeDateFormatting();
  } catch (e, st) {
    assert(() {
      debugPrint('⚠️  Locale init failed: $e\n$st');
      return true;
    }());
  }
}

Future<SharedPreferences> _loadPrefs() async {
  try {
    return await SharedPreferences.getInstance();
  } catch (e, st) {
    assert(() {
      debugPrint('⚠️  SharedPreferences init failed: $e\n$st');
      return true;
    }());
    rethrow;
  }
}