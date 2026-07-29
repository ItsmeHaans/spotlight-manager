import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final shortcuts = [
      // native Dart — a plain list of data, not widgets yet
      ('Routines', Icons.checklist, '/routines'),
      ('Goals', Icons.flag, '/goals'),
      ('Shopping', Icons.shopping_cart, '/shopping'),
      ('Calendar', Icons.calendar_today, '/calendar'),
      ('Transactions', Icons.attach_money, '/transactions'),
      ('Notes', Icons.note, '/notes'),
      ('Wishlist', Icons.favorite, '/wishlist'),
      ('Stats', Icons.bar_chart, '/stats'),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text("Dashboard", style: TextStyle(color: colors.textPrimary)),
      ),
      body: GridView.builder(
        // native Flutter — same grid pattern as Routines
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // native Flutter
          crossAxisCount: isDesktop
              ? 4
              : 2, // 4 columns desktop, 2 columns mobile
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
        ),
        itemCount: shortcuts.length,
        itemBuilder: (context, index) {
          final (label, icon, route) =
              shortcuts[index]; // native Dart — record destructuring
          return AppCard(
            onTap: () => context.go(route),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: colors.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: AppTypography.body.copyWith(color: colors.textPrimary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
