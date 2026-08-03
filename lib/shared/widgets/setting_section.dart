import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final AppColors colors;
  final List<Widget> children; // a list of SettingsTiles, or anything else

  const SettingsSection({
    super.key,
    required this.title,
    required this.colors,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            title
                .toUpperCase(), // native Dart String method — common convention for section headers
            style: AppTypography.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppColors colors;
  final Widget? trailing; // e.g. a Switch, a chevron arrow, or nothing
  final VoidCallback? onTap;
  final Color?
  labelColor; // optional override — remember this pattern from AppTextField?

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    required this.colors,
    this.trailing,
    this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // native Flutter — like GestureDetector, but shows a tap ripple effect (needs Material ancestor)
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: labelColor ?? colors.textPrimary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                  color: labelColor ?? colors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
