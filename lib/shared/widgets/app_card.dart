import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const AppCard({super.key, required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    final colors =
        AppThemes.blueLight; // placeholder, same as the others for now

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
