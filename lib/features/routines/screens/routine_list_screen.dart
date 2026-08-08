// features/routines/screens/routine_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../models/routine.dart';
import '../providers/routine_providers.dart';
import '../providers/routine_filter_provider.dart';
import '../widgets/routine_options_sheet.dart';

class RoutineListScreen extends ConsumerWidget {
  const RoutineListScreen({super.key});

  Future<void> _showRoutineContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
    Routine routine,
  ) async {
    final colors = AppThemes.of(ref.read(themeProvider));
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: colors.error)),
        ),
      ],
    );

    if (!context.mounted) return;

    if (selected == 'edit') {
      context.go('/routines/edit/${routine.id}');
    } else if (selected == 'delete') {
      showDialog(
        context: context,
        builder: (_) => ConfirmDialog(
          title: "Delete Routine?",
          message: "Remove '${routine.title}' and its history?",
          onConfirm: () async {
            await ref.read(routineServiceProvider).deleteRoutine(routine.id);
            ref.invalidate(routineListProvider);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppThemes.of(ref.watch(themeProvider));
    final routinesAsync = ref.watch(routineListProvider);
    final dateState = ref.watch(routineDateFilterProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text("Routine"),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => openRoutineOptionsSheet(context, ref),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: SvgPicture.asset(
                colors.settingPath,
                width: 22,
                height: 22,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _DateBulletHeader(
            rangeStart: dateState.rangeStart,
            rangeEnd: dateState.rangeEnd,
            selectedDate: dateState.selectedDate,
            colors: colors,
            onDateSelected: (date) =>
                ref.read(routineDateFilterProvider.notifier).selectDate(date),
          ),
          const Divider(height: 1),
          Expanded(
            child: routinesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
              data: (routines) {
                if (routines.isEmpty) {
                  return const EmptyState(
                    message: "No routines for this day yet.",
                    icon: Icons.checklist,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GestureDetector(
                        onLongPressStart: (details) => _showRoutineContextMenu(
                          context,
                          ref,
                          details.globalPosition,
                          routine,
                        ),
                        onSecondaryTapDown: (details) =>
                            _showRoutineContextMenu(
                              context,
                              ref,
                              details.globalPosition,
                              routine,
                            ),
                        child: AppCard(
                          onTap: () {
                            // TODO: tandai progress untuk `dateState.selectedDate`
                            // ref.read(routineServiceProvider).logProgress(routine.id, dateState.selectedDate, ...);
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  routine.title,
                                  style: AppTypography.body.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.radio_button_unchecked,
                                color: colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBulletHeader extends StatelessWidget {
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final DateTime selectedDate;
  final AppColors colors;
  final ValueChanged<DateTime> onDateSelected;

  const _DateBulletHeader({
    required this.rangeStart,
    required this.rangeEnd,
    required this.selectedDate,
    required this.colors,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final totalDays = rangeEnd.difference(rangeStart).inDays + 1;
    final days = List.generate(
      totalDays,
      (i) => rangeStart.add(Duration(days: i)),
    );

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // sudah scrollable dari awal
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, today);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 44,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.primary : Colors.transparent,
                border: isToday && !isSelected
                    ? Border.all(color: colors.primary, width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: AppTypography.body.copyWith(
                  color: isSelected ? colors.textSecondary : colors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
