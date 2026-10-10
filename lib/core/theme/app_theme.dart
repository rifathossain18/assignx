import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  // ═══════════════════════════════════════════════════════════
  // BRAND TOKENS (matches AppConstants palette)
  // ═══════════════════════════════════════════════════════════
  static const Color brandStart = Color(0xFF6366F1); // Indigo
  static const Color brandEnd = Color(0xFF8B5CF6);   // Violet
  static const Color brandAccent = Color(0xFF06B6D4); // Cyan
  static const Color brandGold = Color(0xFFF59E0B);   // Amber

  // Light surfaces
  static const Color lightBg = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF1F2F8);

  // Dark surfaces
  static const Color darkBg = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF0F0F16);
  static const Color darkSurfaceElevated = Color(0xFF1A1A24);

  // Text
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // ═══════════════════════════════════════════════════════════
  // PUBLIC THEME BUILDERS
  // ═══════════════════════════════════════════════════════════

  /// Light theme — kept for backward compatibility.
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: brandStart,
      brightness: Brightness.light,
    );

    return _buildTheme(
      base: base,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandStart,
        brightness: Brightness.light,
      ).copyWith(
        primary: brandStart,
        secondary: brandAccent,
        tertiary: brandGold,
        surface: lightSurface,
        surfaceContainerHighest: lightSurfaceMuted,
      ),
      scaffoldBg: lightBg,
      textColor: lightText,
    );
  }

  /// Dark theme — pairs with [light].
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: brandStart,
      brightness: Brightness.dark,
    );

    return _buildTheme(
      base: base,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandStart,
        brightness: Brightness.dark,
      ).copyWith(
        primary: brandStart,
        secondary: brandAccent,
        tertiary: brandGold,
        surface: darkSurface,
        surfaceContainerHighest: darkSurfaceElevated,
      ),
      scaffoldBg: darkBg,
      textColor: darkText,
    );
  }

  /// Convenience: pick theme by brightness.
  static ThemeData of(Brightness brightness) {
    return brightness == Brightness.dark ? dark() : light();
  }

  // ═══════════════════════════════════════════════════════════
  // INTERNAL THEME BUILDER
  // ═══════════════════════════════════════════════════════════
  static ThemeData _buildTheme({
    required ThemeData base,
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color textColor,
  }) {
    final isDark = brightness == Brightness.dark;

    // ── Typography ──
    // Base text theme from Hind Siliguri (Bengali-friendly).
    final baseText = GoogleFonts.hindSiliguriTextTheme(base.textTheme);

    // Apply our semantic text styles on top (colors, weights, spacing).
    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: textColor,
        letterSpacing: -1,
      ),
      displayMedium: baseText.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.6,
      ),
      headlineLarge: baseText.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.5,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -0.4,
      ),
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.3,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        color: textColor.withOpacity(0.92),
        height: 1.55,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        color: textColor.withOpacity(0.85),
        height: 1.55,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        color: textColor.withOpacity(0.7),
      ),
      labelLarge: baseText.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );

    // ── Component themes ──
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      canvasColor: scaffoldBg,

      // ── AppBar ──
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: isDark ? darkBg : lightBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textColor,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: textColor,
        ),
        iconTheme: IconThemeData(color: textColor, size: 20),
      ),

      // ── Filled Button (primary CTA) ──
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandStart,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),

      // ── Elevated Button ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? darkSurfaceElevated : Colors.white,
          foregroundColor: brandStart,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // ── Outlined Button ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandStart,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: brandStart.withOpacity(isDark ? 0.5 : 0.35),
            width: 1.4,
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Text Button ──
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandStart,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input fields ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.025),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: brandStart, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.6),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: textColor.withOpacity(0.65),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: textColor.withOpacity(0.4),
        ),
        helperStyle: textTheme.bodySmall,
      ),

      // ── Cards ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? darkSurfaceElevated : Colors.white,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        thickness: 1,
        space: 1,
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? darkSurfaceElevated : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
        contentTextStyle: textTheme.bodyMedium,
      ),

      // ── Snackbar ──
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? darkSurfaceElevated : brandStart,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),

      // ── Popup Menu ──
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? darkSurfaceElevated : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: textColor),
      ),

      // ── Tooltip ──
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // ── Slider ──
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: brandStart,
        inactiveTrackColor: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.08),
        thumbColor: Colors.white,
        overlayColor: brandStart.withOpacity(0.15),
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 9,
          elevation: 3,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),

      // ── TabBar ──
      tabBarTheme: TabBarThemeData(
        labelColor: brandStart,
        unselectedLabelColor: isDark
            ? Colors.white.withOpacity(0.6)
            : Colors.black.withOpacity(0.55),
        indicatorColor: brandStart,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── Navigation Bar (mobile) ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? darkSurface : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: brandStart.withOpacity(0.15),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: brandStart, size: 22);
          }
          return IconThemeData(
            color: isDark
                ? Colors.white.withOpacity(0.55)
                : Colors.black.withOpacity(0.5),
            size: 22,
          );
        }),
      ),

      // ── Icon ──
      iconTheme: IconThemeData(
        color: isDark
            ? Colors.white.withOpacity(0.8)
            : Colors.black.withOpacity(0.75),
        size: 20,
      ),

      // ── Splash / Ripple ──
      splashColor: brandStart.withOpacity(0.10),
      highlightColor: brandStart.withOpacity(0.05),

      // ── Page transitions ──
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // GRADIENT HELPERS (bonus)
  // ═══════════════════════════════════════════════════════════
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandStart, brandEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [brandAccent, Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [brandGold, Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}