import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';

class HomeShell extends ConsumerWidget {
  // native Riverpod — needs ref to read the current theme
  final Widget
  child; // whichever feature screen is currently active, handed in by the router
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));
    final width = MediaQuery.of(
      context,
    ).size.width; // native Flutter — current screen width
    final isDesktop =
        width >= 900; // your chosen breakpoint — tweak later if needed

    return Scaffold(
      backgroundColor: colors.background,
      body: isDesktop
          ? Row(
              // native Flutter — desktop: sidebar beside content
              children: [
                _Sidebar(colors: colors),
                Expanded(
                  child: child,
                ), // native Flutter — takes all remaining width
              ],
            )
          : child, // mobile: just the content, no sidebar
      bottomNavigationBar: isDesktop
          ? null
          : _BottomNav(colors: colors), // native Flutter widget
    );
  }
}

class _Sidebar extends StatelessWidget {
  final AppColors colors;
  const _Sidebar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: colors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(
            "Spotlight Manager",
            style: AppTypography.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          _NavItem(label: "Dashboard", route: '/home'),
          _NavItem(label: "Routines", route: '/routines'),
          _NavItem(label: "Goals", route: '/goals'),
          // ... one _NavItem per feature, added as each feature gets built
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String route;
  const _NavItem({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // native Flutter widget — a standard tappable row (icon/text + tap behavior)
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => context.go(route), // native GoRouter
    );
  }
}

class _BottomNav extends StatelessWidget {
  final AppColors colors;
  const _BottomNav({required this.colors});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // native Flutter widget
      backgroundColor: colors.background,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.textSecondary,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/quick-input');
            break;
          case 2:
            context.go('/settings');
            break;
        }
      },
      items: const [
        // native property
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: "Quick Input",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
