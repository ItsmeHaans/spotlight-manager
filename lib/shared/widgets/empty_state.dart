import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData?
  icon; // native Flutter type — represents a built-in icon glyph

  const EmptyState({super.key, required this.message, this.icon});

  @override
  Widget build(BuildContext context) {
    final colors =
        AppThemes.blueLight; // placeholder, same as the others for now

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
