import 'package:flutter/material.dart';

import '../../features/about/presentation/about_screen.dart';
import '../../features/editor/presentation/editor_screen.dart';
import '../../features/home/presentation/home_screen.dart';

// ═══════════════════════════════════════════════════════════════
// ROUTE NAMES — centralized, typo-proof
// ═══════════════════════════════════════════════════════════════
class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const editor = '/editor';
  static const about = '/about';

  /// All registered route names — useful for tests / analytics.
  static const List<String> all = [home, editor, about];
}

// ═══════════════════════════════════════════════════════════════
// PAGE TRANSITION — smooth fade + subtle slide
// ═══════════════════════════════════════════════════════════════
class _PremiumPageRoute<T> extends PageRouteBuilder<T> {
  _PremiumPageRoute({
    required this.builder,
    required String routeName,
    this.axis = Axis.horizontal,
  }) : super(
          settings: RouteSettings(name: routeName),
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final beginOffset = axis == Axis.horizontal
                ? const Offset(0.04, 0)
                : const Offset(0, 0.04);

            return FadeTransition(
              opacity: curve,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: beginOffset,
                  end: Offset.zero,
                ).animate(curve),
                child: child,
              ),
            );
          },
        );

  final WidgetBuilder builder;
  final Axis axis;
}

// ═══════════════════════════════════════════════════════════════
// ROUTE GENERATOR — single source of truth for navigation
// ═══════════════════════════════════════════════════════════════
class AppRouter {
  const AppRouter._();

  /// Route generator for `MaterialApp.onGenerateRoute`.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _PremiumPageRoute(
          builder: (_) => const HomeScreen(),
          routeName: AppRoutes.home,
          axis: Axis.vertical,
        );
      case AppRoutes.editor:
        return _PremiumPageRoute(
          builder: (_) => const EditorScreen(),
          routeName: AppRoutes.editor,
          axis: Axis.horizontal,
        );
      case AppRoutes.about:
        return _PremiumPageRoute(
          builder: (_) => const AboutScreen(),
          routeName: AppRoutes.about,
          axis: Axis.vertical,
        );
      default:
        return null;
    }
  }

  /// Optional: handle unknown routes with a friendly fallback.
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => _UnknownRouteScreen(routeName: settings.name),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LEGACY MAP — still exported for backward compatibility
// (If you use `MaterialApp.routes`, this keeps working.)
// ═══════════════════════════════════════════════════════════════
final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.home: (_) => const HomeScreen(),
  AppRoutes.editor: (_) => const EditorScreen(),
  AppRoutes.about: (_) => const AboutScreen(),
};

// ═══════════════════════════════════════════════════════════════
// NAVIGATION HELPERS — bonus convenience methods
// ═══════════════════════════════════════════════════════════════
extension AppNavigator on BuildContext {
  /// Push a named route with the premium transition.
  Future<T?> pushPremium<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replace current route with a named one.
  Future<T?> replacePremium<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed<T, T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Pop back to Home cleanly.
  void goHome() {
    Navigator.of(this).popUntil((route) => route.isFirst);
  }
}

// ═══════════════════════════════════════════════════════════════
// UNKNOWN ROUTE FALLBACK — friendly 404 screen
// ═══════════════════════════════════════════════════════════════
class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.explore_off_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Page not found',
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              if (routeName != null)
                Text(
                  '"$routeName"',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.5),
                    fontFamily: 'monospace',
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: const Text('Go Home'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}