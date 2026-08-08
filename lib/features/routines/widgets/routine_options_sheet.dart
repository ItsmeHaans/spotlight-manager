import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../providers/routine_display_filter_provider.dart';
import '../providers/routine_filter_provider.dart';

void openRoutineOptionsSheet(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    barrierColor: Colors.black45,
    builder: (dialogContext) => Consumer(
      builder: (context, ref, _) {
        final currentTheme = ref.watch(themeProvider);
        final isDark = currentTheme.name.contains('Dark');
        final liveColors = AppThemes.of(currentTheme);

        final screenSize = MediaQuery.of(context).size;
        final isDesktop = screenSize.width >= 700; // breakpoint kamu
        const baseHeight = 340.0;
        final maxHeight = math.min(
          isDesktop ? baseHeight * 3 : baseHeight,
          screenSize.height * 0.85,
        );

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
                    // ============ BASE ============
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

                    // ============ ADDON: Routine — Filter by Date ============
                    const Divider(),
                    Text(
                      "Filter by Date",
                      style: AppTypography.caption.copyWith(
                        color: liveColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Consumer(
                      builder: (context, ref, _) {
                        final dateState = ref.watch(routineDateFilterProvider);

                        if (!isDesktop) {
                          // ---- Phone: week navigator ----
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: liveColors.textPrimary,
                                ),
                                onPressed: () => ref
                                    .read(routineDateFilterProvider.notifier)
                                    .changeWeek(-1),
                              ),
                              GestureDetector(
                                onTap: () => ref
                                    .read(routineDateFilterProvider.notifier)
                                    .resetToToday(),
                                child: Text(
                                  "Week of ${dateState.rangeStart.day}/${dateState.rangeStart.month}",
                                  style: AppTypography.body.copyWith(
                                    color: liveColors.textTitle,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: liveColors.textPrimary,
                                ),
                                onPressed: () => ref
                                    .read(routineDateFilterProvider.notifier)
                                    .changeWeek(1),
                              ),
                            ],
                          );
                        }

                        // ---- Desktop: custom from - to ----
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _DatePickerField(
                                    label: "From",
                                    date: dateState.rangeStart,
                                    colors: liveColors,
                                    onPicked: (picked) => ref
                                        .read(
                                          routineDateFilterProvider.notifier,
                                        )
                                        .setCustomRange(
                                          picked,
                                          dateState.rangeEnd,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _DatePickerField(
                                    label: "To",
                                    date: dateState.rangeEnd,
                                    colors: liveColors,
                                    onPicked: (picked) => ref
                                        .read(
                                          routineDateFilterProvider.notifier,
                                        )
                                        .setCustomRange(
                                          dateState.rangeStart,
                                          picked,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            TextButton(
                              onPressed: () => ref
                                  .read(routineDateFilterProvider.notifier)
                                  .resetToToday(),
                              child: const Text("Reset to This Week"),
                            ),
                          ],
                        );
                      },
                    ),
                    // ============ ADDON: Routine — Display Options ============
                    const Divider(),
                    Consumer(
                      builder: (context, ref, _) {
                        final display = ref.watch(routineDisplayFilterProvider);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SwitchListTile(
                              title: Text(
                                "Show Inactive Routines",
                                style: TextStyle(color: liveColors.textTitle),
                              ),
                              value: display.showInactive,
                              onChanged: (value) => ref
                                  .read(routineDisplayFilterProvider.notifier)
                                  .toggleShowInactive(value),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              "Type",
                              style: AppTypography.caption.copyWith(
                                color: liveColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.xs,
                              children: [
                                ChoiceChip(
                                  label: const Text("All"),
                                  selected: display.trackingType == null,
                                  selectedColor: liveColors.primary,
                                  onSelected: (_) => ref
                                      .read(
                                        routineDisplayFilterProvider.notifier,
                                      )
                                      .setTrackingType(null),
                                ),
                                ChoiceChip(
                                  label: const Text("Checklist"),
                                  selected: display.trackingType == 'checklist',
                                  selectedColor: liveColors.primary,
                                  onSelected: (_) => ref
                                      .read(
                                        routineDisplayFilterProvider.notifier,
                                      )
                                      .setTrackingType('checklist'),
                                ),
                                ChoiceChip(
                                  label: const Text("Counter"),
                                  selected: display.trackingType == 'counter',
                                  selectedColor: liveColors.primary,
                                  onSelected: (_) => ref
                                      .read(
                                        routineDisplayFilterProvider.notifier,
                                      )
                                      .setTrackingType('counter'),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    // ---- CRUD entry point ----
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.add_circle_outline,
                        color: liveColors.primary,
                      ),
                      title: Text(
                        "Add Routine",
                        style: TextStyle(color: liveColors.textTitle),
                      ),
                      onTap: () {
                        Navigator.pop(dialogContext);
                        context.go('/routines/add');
                      },
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

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final AppColors colors;
  final ValueChanged<DateTime> onPicked;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.colors,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colors.secondary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            Text(
              "${date.day}/${date.month}/${date.year}",
              style: AppTypography.body.copyWith(color: colors.textTitle),
            ),
          ],
        ),
      ),
    );
  }
}
