import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/theme_provider.dart';

class EmptyState extends ConsumerWidget {
  final String message;
  final IconData?
  icon; // native Flutter type — represents a built-in icon glyph

  const EmptyState({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(
      ref.watch(themeProvider),
    ); // placeholder, same as the others for now

    return Center(
      // native Flutter widget
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // native property
        children: [
          if (icon != null)
            Icon(icon, size: 48, color: colors.secondary), // native widget
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.body.copyWith(color: colors.secondary),
          ),
        ],
      ),
    );
  }
}
