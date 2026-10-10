import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class AssignX extends ConsumerWidget {
  const AssignX({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);

    return MaterialApp(
      // ── Identity ──
      title: s.t('appName'),
      debugShowCheckedModeBanner: false,

      // ── Theme ──
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,

      // ── Navigation ──
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,

      // ── Text scale clamp (accessibility) ──
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final scale = media.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: media.copyWith(textScaler: scale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}