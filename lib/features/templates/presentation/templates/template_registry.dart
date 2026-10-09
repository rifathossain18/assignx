import 'package:flutter/material.dart';

import '../../domain/template_config.dart';
import '../../domain/template_info.dart';
import 'bengali_traditional.dart';
import 'classic_border.dart';
import 'elegant_gold.dart';
import 'geometric_blue.dart';
import 'gradient_wave.dart';
import 'modern_minimal.dart';
import 'sidebar_split.dart';
import 'university_formal.dart';

/// THE one place to register a template.
/// To add a new one: create the widget, then add a TemplateInfo below.
class TemplateRegistry {
  const TemplateRegistry._();

  // ═══════════════════════════════════════════════════════════
  // SHARED CONSTANTS
  // ═══════════════════════════════════════════════════════════

  static const _allCategories = {
    TemplateCategory.school,
    TemplateCategory.college,
    TemplateCategory.university,
  };

  // ═══════════════════════════════════════════════════════════
  // REGISTRY — all templates in one place
  // ═══════════════════════════════════════════════════════════

  static final List<TemplateInfo> all = [
    // ═════════════════════════════════════════════════════════
    // 1. CLASSIC BORDER
    // ═════════════════════════════════════════════════════════
    TemplateInfo(
      id: 'classic_border',
      name: 'Classic Border',
      nameBn: 'ক্লাসিক বর্ডার',
      style: TemplateStyle.classic,
      categories: _allCategories,
      primary: const Color(0xFF1E3A8A),
      secondary: const Color(0xFFF59E0B),
      font: 'Hind Siliguri',
      tags: const {'traditional', 'formal', 'framed'},
      builder: (a) => ClassicBorderTemplate(a),
    ),

    // ═════════════════════════════════════════════════════════
    // 2. MODERN MINIMAL
    // ═════════════════════════════════════════════════════════
    TemplateInfo(
      id: 'modern_minimal',
      name: 'Modern Minimal',
      nameBn: 'মডার্ন মিনিমাল',
      style: TemplateStyle.minimal,
      categories: _allCategories,
      primary: const Color(0xFF1D4ED8),
      secondary: const Color(0xFF38BDF8),
      font: 'Inter',
      border: BorderStyleType.none,
      alignment: ContentAlign.left,
      tags: const {'clean', 'whitespace', 'sans'},
      builder: (a) => ModernMinimalTemplate(a),
    ),

    // ═════════════════════════════════════════════════════════
    // 3. GRADIENT WAVE
    // ═════════════════════════════════════════════════════════
    TemplateInfo(
      id: 'gradient_wave',
      name: 'Gradient Wave',
      nameBn: 'গ্র্যাডিয়েন্ট ওয়েভ',
      style: TemplateStyle.colorful,
      categories: _allCategories,
      primary: const Color(0xFF7C3AED),
      secondary: const Color(0xFFEC4899),
      font: 'Poppins',
      border: BorderStyleType.none,
      isPremium: true,
      tags: const {'vibrant', 'gradient', 'bold'},
      builder: (a) => GradientWaveTemplate(a),
    ),

    // ═════════════════════════════════════════════════════════
    // 4. UNIVERSITY FORMAL
    // ═════════════════════════════════════════════════════════
    TemplateInfo(
      id: 'university_formal',
      name: 'University Formal',
      nameBn: 'ইউনিভার্সিটি ফরমাল',
      style: TemplateStyle.university,
      categories: {
        TemplateCategory.college,
        TemplateCategory.university,
      },
      primary: const Color(0xFF7F1D1D),
      secondary: const Color(0xFFD4AF37),
      font: 'Playfair Display',
      tags: const {'academic', 'formal', 'traditional'},
      builder: (a) => UniversityFormalTemplate(a),
    ),

    // ═════════════════════════════════════════════════════════
    // 5. GEOMETRIC BLUE
    // ═════════════════════════════════════════════════════════
    TemplateInfo(
      id: 'geometric_blue',
      name: 'Geometric Blue',
      nameBn: 'জিওমেট্রিক ব্লু',
      style: TemplateStyle.modern,
      categories: _allCategories,
      primary: const Color(0xFF1D4ED8),
      secondary: const Color(0xFF38BDF8),
      font: 'Poppins',
      border: BorderStyleType.none,
      tags: const {'geometric', 'modern', 'abstract'},
      builder: (a) => GeometricBlueTemplate(a),
    ),

    // ═════════════════════════════════════════════════════════
    // 6. SIDEBAR SPLIT
    // ═════════════════════════════════════════════════════════
    TemplateInfo(
      id: 'sidebar_split',
      name: 'Sidebar Split',
      nameBn: 'সাইডবার স্প্লিট',
      style: TemplateStyle.modern,
      categories: _allCategories,
      primary: const Color(0xFF0F766E),
      secondary: const Color(0xFFF59E0B),
      font: 'Inter',
      border: BorderStyleType.none,
      alignment: ContentAlign.left,
      tags: const {'editorial', 'sidebar', 'clean'},
      builder: (a) => SidebarSplitTemplate(a),
    ),

    // ═════════════════════════════════════════════════════════
    // 7. ELEGANT GOLD
    // ═════════════════════════════════════════════════════════
    TemplateInfo(
      id: 'elegant_gold',
      name: 'Elegant Gold',
      nameBn: 'এলিগেন্ট গোল্ড',
      style: TemplateStyle.classic,
      categories: {
        TemplateCategory.college,
        TemplateCategory.university,
      },
      primary: const Color(0xFF0F172A),
      secondary: const Color(0xFFD4AF37),
      font: 'Playfair Display',
      isPremium: true,
      tags: const {'luxury', 'gold', 'dark'},
      builder: (a) => ElegantGoldTemplate(a),
    ),

    // ═════════════════════════════════════════════════════════
    // 8. BENGALI TRADITIONAL
    // ═════════════════════════════════════════════════════════
    TemplateInfo(
      id: 'bengali_traditional',
      name: 'Bengali Traditional',
      nameBn: 'বাংলা ঐতিহ্য',
      style: TemplateStyle.colorful,
      categories: _allCategories,
      primary: const Color(0xFFB91C1C),
      secondary: const Color(0xFFF59E0B),
      font: 'Hind Siliguri',
      border: BorderStyleType.none,
      isPremium: true,
      tags: const {'alpona', 'bengali', 'heritage', 'ornate'},
      builder: (a) => BengaliTraditionalTemplate(a),
    ),
  ];

  // ═══════════════════════════════════════════════════════════
  // LOOKUPS
  // ═══════════════════════════════════════════════════════════

  /// Look up a template by id.
  /// Falls back to the first template if the id doesn't exist.
  static TemplateInfo byId(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);

  /// Safe lookup — returns `null` if not found.
  static TemplateInfo? tryById(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// True when a template with this id exists.
  static bool has(String id) => all.any((t) => t.id == id);

  /// Total number of registered templates.
  static int get count => all.length;

  // ═══════════════════════════════════════════════════════════
  // QUERIES
  // ═══════════════════════════════════════════════════════════

  /// All templates in a specific style.
  static List<TemplateInfo> byStyle(TemplateStyle style) =>
      all.where((t) => t.style == style).toList();

  /// All templates that fit a specific category.
  static List<TemplateInfo> byCategory(TemplateCategory category) =>
      all.where((t) => t.categories.contains(category)).toList();

  /// All premium templates (for a "Premium" section in the gallery).
  static List<TemplateInfo> get premium =>
      all.where((t) => t.isPremium).toList();

  /// All free templates.
  static List<TemplateInfo> get free =>
      all.where((t) => !t.isPremium).toList();

  /// Templates matching a search query (name, nameBn, id, or tags).
  static List<TemplateInfo> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((t) {
      return t.name.toLowerCase().contains(q) ||
          t.nameBn.contains(q) ||
          t.id.toLowerCase().contains(q) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();
  }

  /// Advanced filter — combine style, category, and query.
  static List<TemplateInfo> filter({
    TemplateStyle? style,
    TemplateCategory? category,
    String? query,
    bool? premiumOnly,
  }) {
    final q = query?.trim().toLowerCase() ?? '';

    return all.where((t) {
      if (style != null && t.style != style) return false;
      if (category != null && !t.categories.contains(category)) {
        return false;
      }
      if (premiumOnly == true && !t.isPremium) return false;
      if (premiumOnly == false && t.isPremium) return false;
      if (q.isNotEmpty) {
        final hits = t.name.toLowerCase().contains(q) ||
            t.nameBn.contains(q) ||
            t.id.toLowerCase().contains(q) ||
            t.tags.any((tag) => tag.toLowerCase().contains(q));
        if (!hits) return false;
      }
      return true;
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════

  /// Total number of unique tags across all templates.
  static Set<String> get allTags =>
      all.expand((t) => t.tags).toSet();

  /// Unique styles present in the registry.
  static Set<TemplateStyle> get allStyles =>
      all.map((t) => t.style).toSet();

  /// Unique categories covered by the registry.
  static Set<TemplateCategory> get allCategories =>
      all.expand((t) => t.categories).toSet();

  /// Find the next template id in the registry (wraps around).
  static String nextId(String currentId) {
    final idx = all.indexWhere((t) => t.id == currentId);
    if (idx < 0) return all.first.id;
    return all[(idx + 1) % all.length].id;
  }

  /// Find the previous template id in the registry (wraps around).
  static String previousId(String currentId) {
    final idx = all.indexWhere((t) => t.id == currentId);
    if (idx < 0) return all.last.id;
    return all[(idx - 1 + all.length) % all.length].id;
  }
}