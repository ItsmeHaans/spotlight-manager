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
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: child),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: screenHeight * 0.03, // 10% from bottom
                      child: Center(child: AppBottomNav(colors: colors)),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: null,
    );
  }
}
