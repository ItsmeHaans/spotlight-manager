import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_provider.dart';

enum AppButtonVariant { primary, secondary, danger }

class AppButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));

    late final Color backgroundColor;
    late final Color foregroundColor;
    late final Color disabledBackgroundColor;
    late final Color disabledForegroundColor;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.primary;
        foregroundColor = colors.background;
        break;

      case AppButtonVariant.secondary:
        backgroundColor = colors.secondary;
        foregroundColor = colors.textTitle;
        break;

      case AppButtonVariant.danger:
        backgroundColor = colors.error;
        foregroundColor = Colors.white;
        break;
    }

    disabledBackgroundColor = colors.secondary.withOpacity(0.5);
    disabledForegroundColor = foregroundColor.withOpacity(0.7);

    // Bumped up from AppTypography.body — on phone-sized screens the
    // default body size read too small/light for a primary tap target.
    final labelStyle = AppTypography.body.copyWith(
      color: foregroundColor,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: disabledForegroundColor,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: labelStyle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: foregroundColor,
                  ),
                )
              : Text(label, key: const ValueKey('label'), style: labelStyle),
        ),
      ),
    );
  }
}
