import 'package:flutter/material.dart';

/// Bundled fonts — loaded SYNCHRONOUSLY by Flutter's engine.
///
/// Fonts are packaged in `assets/fonts/` and registered in
/// `pubspec.yaml`. No network access → instant font change,
/// text ALWAYS visible, works offline.
class AppFonts {
  const AppFonts._();

  // ═══════════════════════════════════════════════════════════
  // FONT FAMILIES — must match pubspec.yaml family names EXACTLY
  // ═══════════════════════════════════════════════════════════
  static const List<String> families = [
    'Hind Siliguri',
    'Noto Sans Bengali',
    'Inter',
    'Poppins',
    'Playfair Display',
  ];

  /// Bengali-capable fonts.
  static const List<String> bengaliFamilies = [
    'Hind Siliguri',
    'Noto Sans Bengali',
  ];

  /// Latin display fonts (great for English covers).
  static const List<String> displayFamilies = [
    'Playfair Display',
    'Poppins',
    'Inter',
  ];

  static const String defaultFamily = 'Hind Siliguri';

  // ═══════════════════════════════════════════════════════════
  // PRELOAD — no-op for bundled fonts (they load instantly)
  // ═══════════════════════════════════════════════════════════
  static Future<void> preloadAll() async {
    // Bundled fonts are loaded synchronously by Flutter.
    // Nothing to do here.
  }

  // ═══════════════════════════════════════════════════════════
  // STYLE — returns a TextStyle using a bundled font
  // ═══════════════════════════════════════════════════════════
  /// [family] must be one of [families] — otherwise falls back to
  /// [defaultFamily] which is always bundled.
  static TextStyle style(
    String family, {
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
  }) {
    final resolvedFamily =
        families.contains(family) ? family : defaultFamily;

    return TextStyle(
      fontFamily: resolvedFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════

  /// True if [family] is one of the bundled families.
  static bool isKnown(String family) => families.contains(family);

  /// Returns [family] if known, else [defaultFamily].
  static String resolve(String? family) {
    if (family == null || family.isEmpty) return defaultFamily;
    return isKnown(family) ? family : defaultFamily;
  }

  /// Bengali-safe letter-spacing: 0 for Bangla (conjuncts would break),
  /// [value] for Latin scripts.
  static double safeLetterSpacing(double value, {required bool isBangla}) {
    return isBangla ? 0 : value;
  }

  /// Total number of registered families.
  static int get count => families.length;
}