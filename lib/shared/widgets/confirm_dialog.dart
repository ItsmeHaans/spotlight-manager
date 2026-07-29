import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import 'app_button.dart';
import '../../core/theme/theme_provider.dart';

class ConfirmDialog extends ConsumerWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = "Delete",
    this.cancelLabel = "Cancel",
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));

    // Using a plain Dialog instead of AlertDialog gives full control over
    // padding and the action row, instead of relying on AlertDialog's
    // built-in (fairly awkward) actions layout.
    return Dialog(
      backgroundColor: colors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        // Caps the dialog at the original compact "card" width instead of
        // stretching to fill the available screen width.
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.heading2.copyWith(
                  color: colors.background,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: AppTypography.body.copyWith(color: colors.background),
              ),
              const SizedBox(height: 28),

              // Cancel and Delete share equal visual weight, side by side.
              // Cancel gets a real button boundary (outline) instead of
              // floating as bare text, so it doesn't read as an afterthought.
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.background,
                        side: BorderSide(
                          color: colors.background.withOpacity(0.35),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        cancelLabel,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      variant: AppButtonVariant.danger,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
