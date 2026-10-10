import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../assignment/presentation/providers/assignment_provider.dart';
import '../../domain/cover_args.dart';
import '../../domain/template_info.dart';
import '../providers/template_provider.dart';
import '../templates/template_registry.dart';
import 'template_thumbnail.dart';

class TemplateGallery extends ConsumerStatefulWidget {
  const TemplateGallery({super.key});

  @override
  ConsumerState<TemplateGallery> createState() => _TemplateGalleryState();
}

class _TemplateGalleryState extends ConsumerState<TemplateGallery> {
  TemplateStyle? _style;
  TemplateCategory? _category;
  bool _premiumOnly = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final data = ref.watch(assignmentProvider);
    final selectedId = ref.watch(
      templateConfigProvider.select((c) => c.templateId),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = ref.watch(
      templateConfigProvider.select((c) => c.primaryColor),
    );

    // ── Filter ──
    final q = _query.trim().toLowerCase();
    final list = TemplateRegistry.all.where((t) {
      if (_style != null && t.style != _style) return false;
      if (_category != null && !t.categories.contains(_category)) {
        return false;
      }
      if (_premiumOnly && !t.isPremium) return false;
      if (q.isNotEmpty) {
        final hits = t.name.toLowerCase().contains(q) ||
            t.nameBn.contains(q) ||
            t.id.toLowerCase().contains(q) ||
            t.tags.any((tag) => tag.toLowerCase().contains(q));
        if (!hits) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ═══════════════════════════════════════════════════════
        // SEARCH BAR
        // ═══════════════════════════════════════════════════════
        _SearchBar(
          controller: _searchController,
          isDark: isDark,
          accent: accent,
          hint: s.isBangla ? 'টেমপ্লেট খুঁজুন...' : 'Search templates...',
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 14),

        // ═══════════════════════════════════════════════════════
        // STYLE CHIPS + PREMIUM TOGGLE
        // ═══════════════════════════════════════════════════════
        Row(
          children: [
            Expanded(
              child: Text(
                s.isBangla ? 'স্টাইল' : 'STYLE',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.4),
                ),
              ),
            ),
            _PremiumFilterButton(
              isDark: isDark,
              accent: accent,
              active: _premiumOnly,
              onTap: () => setState(() => _premiumOnly = !_premiumOnly),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChipCustom(
                label: s.t('all'),
                selected: _style == null,
                isDark: isDark,
                accent: accent,
                onTap: () => setState(() => _style = null),
              ),
              const SizedBox(width: 8),
              for (final st in TemplateStyle.values) ...[
                _FilterChipCustom(
                  label: s.t(st.labelKey),
                  selected: _style == st,
                  isDark: isDark,
                  accent: accent,
                  onTap: () => setState(() => _style = st),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ═══════════════════════════════════════════════════════
        // CATEGORY CHIPS
        // ═══════════════════════════════════════════════════════
        Text(
          s.isBangla ? 'ক্যাটাগরি' : 'CATEGORY',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: isDark
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChipCustom(
                label: s.t('all'),
                selected: _category == null,
                isDark: isDark,
                accent: accent,
                onTap: () => setState(() => _category = null),
              ),
              const SizedBox(width: 8),
              for (final cat in TemplateCategory.values) ...[
                _FilterChipCustom(
                  label: s.t(cat.labelKey),
                  selected: _category == cat,
                  isDark: isDark,
                  accent: accent,
                  onTap: () => setState(() => _category = cat),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ═══════════════════════════════════════════════════════
        // RESULTS COUNT
        // ═══════════════════════════════════════════════════════
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(0.12),
                    accent.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: accent.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 13,
                    color: accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${list.length}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              s.isBangla ? 'টি টেমপ্লেট' : 'templates',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.45),
              ),
            ),
            const Spacer(),
            // Clear filters button (only shown when filters active)
            if (_style != null || _category != null || _premiumOnly || q.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _style = null;
                    _category = null;
                    _premiumOnly = false;
                    _query = '';
                    _searchController.clear();
                  });
                },
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: Text(s.isBangla ? 'রিসেট' : 'Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: accent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // ═══════════════════════════════════════════════════════
        // GRID
        // ═══════════════════════════════════════════════════════
        if (list.isEmpty)
          _EmptyState(isDark: isDark, accent: accent)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (_, i) {
              final t = list[i];
              return TemplateThumbnail(
                info: t,
                args: CoverArgs(
                  data: data,
                  config: t.defaultConfig(),
                  strings: s,
                ),
                label: s.isBangla ? t.nameBn : t.name,
                selected: t.id == selectedId,
                onTap: () =>
                    ref.read(templateConfigProvider.notifier).select(t),
              );
            },
          ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// SEARCH BAR
// ═════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.accent,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool isDark;
  final Color accent;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 13.5,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13.5,
            color: isDark
                ? Colors.white.withOpacity(0.35)
                : Colors.black.withOpacity(0.35),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.4),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.4),
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// PREMIUM FILTER BUTTON
// ═════════════════════════════════════════════════════════════
class _PremiumFilterButton extends StatelessWidget {
  const _PremiumFilterButton({
    required this.isDark,
    required this.accent,
    required this.active,
    required this.onTap,
  });

  final bool isDark;
  final Color accent;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF59E0B);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [gold, gold.withOpacity(0.75)],
                )
              : null,
          color: active
              ? null
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08)),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: gold.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 13,
              color: active
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withOpacity(0.6)
                      : Colors.black.withOpacity(0.5)),
            ),
            const SizedBox(width: 5),
            Text(
              'PRO',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: active
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// CUSTOM FILTER CHIP
// ═════════════════════════════════════════════════════════════
class _FilterChipCustom extends StatelessWidget {
  const _FilterChipCustom({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    accent,
                    accent.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected
              ? null
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08)),
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: 0.1,
            color: selected
                ? Colors.white
                : (isDark
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.65)),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// EMPTY STATE
// ═════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark, required this.accent});

  final bool isDark;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(0.15),
                  accent.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: accent.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 32,
              color: accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No templates match your filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try clearing the search or resetting filters',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : Colors.black.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}