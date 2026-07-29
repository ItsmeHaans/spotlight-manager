import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_provider.dart';

class AppCard extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const AppCard({super.key, required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DefaultTextStyle(
          style: AppTypography.body.copyWith(color: colors.background),
          child: IconTheme(
            data: IconThemeData(color: colors.background),
            child: child,
          ),
        ),
      ),
    );
  }
}
