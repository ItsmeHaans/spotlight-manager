import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // native package — add this import
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme.dart';

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
    // TODO: pull colors from the active theme (via Riverpod) instead of a hardcoded example
    final colors = AppThemes.of(
      ref.watch(themeProvider),
    ); // placeholder until theme provider exists

    Color backgroundColor;
    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.primary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colors.secondary;
        break;
      case AppButtonVariant.danger:
        backgroundColor = colors.error;
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: colors.secondary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTypography.body.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
