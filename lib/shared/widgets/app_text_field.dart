import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // native package — add this import
import '../../core/theme/theme_provider.dart';
import '../../core/theme/theme.dart';

class AppTextField extends ConsumerWidget {
  final String? label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final String? errorText;
  final TextInputType keyboardType;
  final int? maxLines;

  const AppTextField({
    super.key,
    this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(
      ref.watch(themeProvider),
    ); // placeholder, same as AppButton for now

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: AppTypography.caption.copyWith(color: colors.background),
          ),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          style: AppTypography.body.copyWith(color: colors.textSecondary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.body.copyWith(color: colors.background),
            errorText: errorText,
            filled: true,
            fillColor: colors.primary,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: maxLines == null || maxLines == 1
                  ? AppSpacing.sm
                  : AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
