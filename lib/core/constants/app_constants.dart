import 'package:flutter/material.dart';

class AppConstants {
  const AppConstants._();

  // ═══════════════════════════════════════════════════════════
  // PAGE DIMENSIONS
  // ═══════════════════════════════════════════════════════════

  /// A4 ratio (210 x 297 mm) in logical pixels.
  static const double pageWidth = 595;
  static const double pageHeight = 842;

  /// A4 aspect ratio (width / height) — handy for placeholders.
  static const double pageAspectRatio = pageWidth / pageHeight;

  /// 595pt * 4.1667 ≈ 2480px  →  ~300 DPI on A4.
  static const double exportPixelRatio = 4.1667;

  /// 600 DPI variant (for ultra-high-quality exports).
  static const double exportPixelRatioHigh = 8.3333;

  // ═══════════════════════════════════════════════════════════
  // LAYOUT
  // ═══════════════════════════════════════════════════════════

  /// Minimum width before switching to the wide (side-by-side) layout.
  static const double wideBreakpoint = 900;

  /// Standard page padding (safe content margin inside the page).
  static const double pagePadding = 48;

  /// Spacing scale — use these for consistent layouts.
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 40;

  /// Corner radius scale.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 20;
  static const double radiusPill = 100;

  // ═══════════════════════════════════════════════════════════
  // ZOOM
  // ═══════════════════════════════════════════════════════════

  static const double zoomMin = 0.3;
  static const double zoomMax = 2.0;
  static const double zoomStep = 0.1;
  static const double zoomDefault = 1.0;

  // ═══════════════════════════════════════════════════════════
  // FONTS
  // ═══════════════════════════════════════════════════════════

  static const List<String> fonts = [
    'Hind Siliguri',
    'Noto Sans Bengali',
    'Inter',
    'Poppins',
    'Playfair Display',
  ];

  /// Bengali-friendly fonts (subset of [fonts]) — useful for filtering.
  static const List<String> bengaliFonts = [
    'Hind Siliguri',
    'Noto Sans Bengali',
  ];

  /// Latin-only display fonts (great for English covers).
  static const List<String> displayFonts = [
    'Playfair Display',
    'Poppins',
    'Inter',
  ];

  static const String defaultFont = 'Hind Siliguri';
  static const String defaultDisplayFont = 'Playfair Display';

  // ═══════════════════════════════════════════════════════════
  // COLOR PALETTE (existing — unchanged for compatibility)
  // ═══════════════════════════════════════════════════════════

  static const List<Color> palette = [
    Color(0xFF1E3A8A),
    Color(0xFF1D4ED8),
    Color(0xFF38BDF8),
    Color(0xFF0F766E),
    Color(0xFF166534),
    Color(0xFF7F1D1D),
    Color(0xFFB91C1C),
    Color(0xFF7C3AED),
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
    Color(0xFFD4AF37),
    Color(0xFF0F172A),
  ];

  /// Named palette entries for semantic use in UI.
  static const Color navy = Color(0xFF1E3A8A);
  static const Color royalBlue = Color(0xFF1D4ED8);
  static const Color sky = Color(0xFF38BDF8);
  static const Color teal = Color(0xFF0F766E);
  static const Color forest = Color(0xFF166534);
  static const Color wine = Color(0xFF7F1D1D);
  static const Color crimson = Color(0xFFB91C1C);
  static const Color violet = Color(0xFF7C3AED);
  static const Color pink = Color(0xFFEC4899);
  static const Color amber = Color(0xFFF59E0B);
  static const Color gold = Color(0xFFD4AF37);
  static const Color ink = Color(0xFF0F172A);

  // ═══════════════════════════════════════════════════════════
  // APP BRAND — premium gradient colors
  // ═══════════════════════════════════════════════════════════

  static const Color brandStart = Color(0xFF6366F1); // Indigo
  static const Color brandEnd = Color(0xFF8B5CF6);   // Violet
  static const Color brandAccent = Color(0xFF06B6D4); // Cyan
  static const Color brandGold = Color(0xFFF59E0B);   // Amber

  /// Ready-to-use brand gradient for buttons, headers, etc.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandStart, brandEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cyan → Blue (used for Preview tab / secondary actions).
  static const LinearGradient accentGradient = LinearGradient(
    colors: [brandAccent, Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold → Red (used for Customize tab / premium highlights).
  static const LinearGradient warmGradient = LinearGradient(
    colors: [brandGold, Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Green → Cyan (used for Secure / success states).
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), brandAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════
  // SURFACES (dark / light theme tokens)
  // ═══════════════════════════════════════════════════════════

  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF0F0F16);
  static const Color darkSurfaceElevated = Color(0xFF1A1A24);

  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF1F2F8);
  static const Color lightCanvas = Color(0xFFEDEEF5);

  // ═══════════════════════════════════════════════════════════
  // MOTION
  // ═══════════════════════════════════════════════════════════

  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionNormal = Duration(milliseconds: 280);
  static const Duration motionSlow = Duration(milliseconds: 600);

  static const Curve motionEaseOut = Curves.easeOutCubic;
  static const Curve motionEaseOutBack = Curves.easeOutBack;
}