// features/shopping/widgets/shopping_options_sheet.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/shopping_provider.dart';
import '../providers/shopping_filter_provider.dart';
import '../models/shopping_category.dart';

void openShoppingOptionsSheet(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierColor: Colors.black45,
    builder: (dialogContext) => Consumer(
      builder: (context, ref, _) {
        final currentTheme = ref.watch(themeProvider);
        final isDark = currentTheme.name.contains('Dark');
        final liveColors = AppThemes.of(currentTheme);

        // --- adaptive sizing: phone stays compact, desktop ~3x taller ---
        final screenSize = MediaQuery.of(context).size;
        final isDesktop = screenSize.width >= 900;
        const baseHeight = 340.0; // roughly the original base sheet's height
        final maxHeight = math.min(
          isDesktop ? baseHeight * 3 : baseHeight,
          screenSize.height * 0.85,
        );

        // --- shopping-specific data for the addon ---
        final itemsAsync = ref.watch(shoppingListProvider);
        final categories = itemsAsync.maybeWhen(
          data: (items) =>
              items.map((i) => i.category).whereType<String>().toSet().toList(),
          orElse: () => <String>[],
        );
        final selectedCategory = ref.watch(shoppingCategoryFilterProvider);

        return Dialog(
          backgroundColor: liveColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ============ BASE (identik di semua halaman) ============
                    SwitchListTile(
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(color: liveColors.textTitle),
                      ),
                      value: isDark,
                      onChanged: (value) {
                        final baseName = currentTheme.name
                            .replaceAll('Light', '')
                            .replaceAll('Dark', '');
                        final newTheme = AppThemeName.values.firstWhere(
                          (t) =>
                              t.name == '$baseName${value ? 'Dark' : 'Light'}',
                        );
                        ref.read(themeProvider.notifier).setTheme(newTheme);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['yellow', 'blue', 'silver', 'pink'].map((
                        color,
                      ) {
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
                              ref
                                  .read(themeProvider.notifier)
                                  .setTheme(newTheme);
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

                    // ============ ADDON: khusus Shopping (punya category) ============
                    const Divider(),
                    Text(
                      "Filter by Category",
                      style: AppTypography.caption.copyWith(
                        color: liveColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: selectedCategory == null,
                          onSelected: (_) => ref
                              .read(shoppingCategoryFilterProvider.notifier)
                              .select(null),
                          selectedColor: liveColors.primary,
                        ),
                        ...ShoppingCategory.values.map(
                          (category) => ChoiceChip(
                            label: Text(category.label),
                            selected: selectedCategory == category,
                            onSelected: (_) => ref
                                .read(shoppingCategoryFilterProvider.notifier)
                                .select(category),
                            selectedColor: liveColors.primary,
                          ),
                        ),
                      ],
                    ),

                    // ============ BASE: logout ============
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.logout, color: liveColors.error),
                      title: Text(
                        "Log Out",
                        style: TextStyle(color: liveColors.error),
                      ),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        Supabase.instance.client.auth.signOut();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
