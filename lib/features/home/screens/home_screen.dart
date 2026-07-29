import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_sidebar.dart'; // NEW

class HomeShell extends ConsumerWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 700;
    final sidebarWidth = width * 0.2284;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: false,
      body: isDesktop
          ? Row(
              children: [
                AppSidebar(colors: colors, width: sidebarWidth),
                Expanded(child: child),
              ],
            )
          : Stack(
              fit: StackFit.expand,
              // mobile — content behind, floating pill on top
              children: [
                Positioned.fill(child: child),
                Align(
                  // native Flutter — positions the pill at the bottom of the Stack
                  alignment: Alignment.bottomCenter,
                  child: AppBottomNav(colors: colors),
                ),
              ],
            ),
      bottomNavigationBar: null,
    );
  }
}
