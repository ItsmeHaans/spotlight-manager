import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/theme_provider.dart';
import 'filter_screen.dart'; // your FilterConfig/FilterType from before

class PageOptionsButton extends ConsumerWidget {
  // was StatelessWidget — needs ref now, for theme switching
  final FilterConfig? filterConfig; // null for Dashboard/Stats
  final VoidCallback?
  onAddPressed; // null for Dashboard/Stats — the "+" action for everything else
  final void Function(dynamic result)? onFilterSelected;

  const PageOptionsButton({
    super.key,
    this.filterConfig,
    this.onAddPressed,
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final iconSize = isDesktop ? 24.0 : 32.0;
    final gap = isDesktop ? AppSpacing.md : AppSpacing.lg;

    return Positioned(
      top: gap,
      right: gap,
      child: GestureDetector(
        onTap: () => _openOptionsSheet(context, ref, colors),
        child: SvgPicture.asset(
          colors.settingPath,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        ),
      ),
    );
  }

  void _openOptionsSheet(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _OptionsSheetContent(
        colors: colors,
        filterConfig: filterConfig,
        onAddPressed: onAddPressed,
        onFilterSelected: onFilterSelected,
      ),
    );
  }
}

class _OptionsSheetContent extends ConsumerWidget {
  final AppColors colors;
  final FilterConfig? filterConfig;
  final VoidCallback? onAddPressed;
  final void Function(dynamic result)? onFilterSelected;

  const _OptionsSheetContent({
    required this.colors,
    required this.filterConfig,
    required this.onAddPressed,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = currentTheme.name.contains('Dark');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // native property — sheet only as tall as its content needs
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BASE SECTION (always present) ---
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDark,
              onChanged: (value) {
                final baseName = currentTheme.name
                    .replaceAll('Light', '')
                    .replaceAll('Dark', '');
                final newTheme = AppThemeName.values.firstWhere(
                  (t) => t.name == '$baseName${value ? 'Dark' : 'Light'}',
                );
                ref.read(themeProvider.notifier).setTheme(newTheme);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['yellow', 'blue', 'silver', 'pink'].map((color) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      final suffix = isDark ? 'Dark' : 'Light';
                      final newTheme = AppThemeName.values.firstWhere(
                        (t) => t.name == '$color$suffix',
                      );
                      ref.read(themeProvider.notifier).setTheme(newTheme);
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppThemes.of(
                        AppThemeName.values.firstWhere(
                          (t) => t.name == '${color}Light',
                        ),
                      ).primary,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (onAddPressed != null) ...[
              // only shown on pages that actually have addable items
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Add New Item"),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed!();
                },
              ),
            ],
            const Divider(), // native Flutter — a thin horizontal line, visually separates base from filter section
            // --- FILTER SECTION (only if this page has one) ---
            if (filterConfig != null)
              _buildFilterSection(context, filterConfig!),

            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text("Log Out", style: TextStyle(color: colors.error)),
              onTap: () {
                Navigator.pop(context);
                Supabase.instance.client.auth.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, FilterConfig config) {
    switch (config.type) {
      case FilterType.category:
        return Wrap(
          spacing: AppSpacing.sm,
          children: config.categoryOptions!.map((opt) {
            return ChoiceChip(
              label: Text(opt),
              selected: false,
              onSelected: (_) {
                Navigator.pop(context);
                onFilterSelected?.call(opt);
              },
            );
          }).toList(),
        );
      case FilterType.singleDate:
        return const Text(
          "Date filter placeholder — circle date list comes later",
        );
      case FilterType.dateRange:
        return ElevatedButton(
          onPressed: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (range != null && context.mounted) {
              Navigator.pop(context);
              onFilterSelected?.call(range);
            }
          },
          child: const Text("Pick date range"),
        );
    }
  }
}
