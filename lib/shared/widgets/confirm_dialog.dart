import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'app_button.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = "Delete",
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colors =
        AppThemes.blueLight; // placeholder, same as the others for now

    return AlertDialog(
      // native Flutter widget — a built-in popup dialog box
      backgroundColor: colors.secondary, // native property
      title: Text(
        title,
        style: AppTypography.heading2.copyWith(color: colors.textPrimary),
      ),
      content: Text(
        message,
        style: AppTypography.body.copyWith(color: colors.textSecondary),
      ),
      actions: [
        // native property — a row of buttons at the bottom of the dialog
        TextButton(
          // native Flutter widget — a plain, low-emphasis button
          onPressed: () =>
              Navigator.of(context).pop(), // native Flutter — closes the dialog
          child: Text("Cancel", style: TextStyle(color: colors.textSecondary)),
        ),
        AppButton(
          label: confirmLabel,
          variant:
              AppButtonVariant.danger, // reusing your existing button variant
          onPressed: () {
            Navigator.of(context).pop(); // close the dialog first
            onConfirm(); // then run whatever action was passed in (e.g. actually delete the item)
          },
        ),
      ],
    );
  }
}
