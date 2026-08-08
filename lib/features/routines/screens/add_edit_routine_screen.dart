// features/routines/screens/add_edit_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/routine.dart';
import '../providers/routine_providers.dart';

class AddEditRoutineScreen extends ConsumerStatefulWidget {
  final Routine? existingRoutine;
  const AddEditRoutineScreen({super.key, this.existingRoutine});

  @override
  ConsumerState<AddEditRoutineScreen> createState() =>
      _AddEditRoutineScreenState();
}

class _AddEditRoutineScreenState extends ConsumerState<AddEditRoutineScreen> {
  late final TextEditingController _titleController;
  String _trackingType = 'checklist'; // 'checklist' | 'counter'
  late final TextEditingController _targetCountController;
  String _frequency =
      'daily'; // 'daily' | 'weekdays' | 'custom_weekly' | 'custom_monthly'
  final Set<int> _selectedWeekdays = {}; // 1=Mon ... 7=Sun
  final Set<int> _selectedMonthDates = {}; // 1-31
  bool _isSaving = false;

  static const _weekdayLabels = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  @override
  void initState() {
    super.initState();
    final existing = widget.existingRoutine;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _targetCountController = TextEditingController(
      text: existing?.targetCount?.toString() ?? '',
    );
    _trackingType = existing?.trackingType ?? 'checklist';
    _frequency = existing?.frequency ?? 'daily';
    if (existing?.frequency == 'custom_weekly') {
      _selectedWeekdays.addAll(existing?.frequencyDetail ?? []);
    } else if (existing?.frequency == 'custom_monthly') {
      _selectedMonthDates.addAll(existing?.frequencyDetail ?? []);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetCountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    List<int>? detail;
    if (_frequency == 'custom_weekly') detail = _selectedWeekdays.toList();
    if (_frequency == 'custom_monthly') detail = _selectedMonthDates.toList();

    final routine = Routine(
      id: widget.existingRoutine?.id ?? '',
      title: _titleController.text.trim(),
      trackingType: _trackingType,
      targetCount: _trackingType == 'counter'
          ? int.tryParse(_targetCountController.text)
          : null,
      frequency: _frequency,
      frequencyDetail: detail,
      isActive: widget.existingRoutine?.isActive ?? true,
    );

    final service = ref.read(routineServiceProvider);
    if (widget.existingRoutine == null) {
      await service.addRoutine(routine);
    } else {
      await service.updateRoutine(widget.existingRoutine!.id, routine);
    }

    ref.invalidate(routineListProvider);
    if (mounted) context.go('/routines');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemes.of(ref.watch(themeProvider));
    final isEditing = widget.existingRoutine != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(isEditing ? "Edit Routine" : "Add Routine")),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ListView(
          children: [
            AppTextField(label: "Title", controller: _titleController),
            const SizedBox(height: AppSpacing.md),

            // ---- Tracking type ----
            Text(
              "Tracking Type",
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: ['checklist', 'counter'].map((type) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(type[0].toUpperCase() + type.substring(1)),
                      selected: _trackingType == type,
                      selectedColor: colors.primary,
                      onSelected: (_) => setState(() => _trackingType = type),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_trackingType == 'counter') ...[
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: "Target Count",
                controller: _targetCountController,
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // ---- Frequency ----
            Text(
              "Frequency",
              style: AppTypography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                ChoiceChip(
                  label: const Text("Daily"),
                  selected: _frequency == 'daily',
                  selectedColor: colors.primary,
                  onSelected: (_) => setState(() => _frequency = 'daily'),
                ),
                ChoiceChip(
                  label: const Text("Weekdays"),
                  selected: _frequency == 'weekdays',
                  selectedColor: colors.primary,
                  onSelected: (_) => setState(() => _frequency = 'weekdays'),
                ),
                ChoiceChip(
                  label: const Text("Custom Weekly"),
                  selected: _frequency == 'custom_weekly',
                  selectedColor: colors.primary,
                  onSelected: (_) =>
                      setState(() => _frequency = 'custom_weekly'),
                ),
                ChoiceChip(
                  label: const Text("Custom Monthly"),
                  selected: _frequency == 'custom_monthly',
                  selectedColor: colors.primary,
                  onSelected: (_) =>
                      setState(() => _frequency = 'custom_monthly'),
                ),
              ],
            ),

            // ---- Custom weekly: pilih hari ----
            if (_frequency == 'custom_weekly') ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                children: _weekdayLabels.entries.map((entry) {
                  final selected = _selectedWeekdays.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: selected,
                    selectedColor: colors.primary,
                    onSelected: (value) => setState(() {
                      value
                          ? _selectedWeekdays.add(entry.key)
                          : _selectedWeekdays.remove(entry.key);
                    }),
                  );
                }).toList(),
              ),
            ],

            // ---- Custom monthly: pilih tanggal ----
            if (_frequency == 'custom_monthly') ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                "Pick date(s) in the month",
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: List.generate(31, (i) => i + 1).map((day) {
                  final selected = _selectedMonthDates.contains(day);
                  return FilterChip(
                    label: Text('$day'),
                    selected: selected,
                    selectedColor: colors.primary,
                    onSelected: (value) => setState(() {
                      value
                          ? _selectedMonthDates.add(day)
                          : _selectedMonthDates.remove(day);
                    }),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: "Save",
              isLoading: _isSaving,
              onPressed: _handleSave,
            ),

            if (isEditing) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                icon: Icon(Icons.delete, color: colors.error),
                label: Text(
                  "Delete Routine",
                  style: TextStyle(color: colors.error),
                ),
                onPressed: () async {
                  await ref
                      .read(routineServiceProvider)
                      .deleteRoutine(widget.existingRoutine!.id);
                  ref.invalidate(routineListProvider);
                  if (mounted) context.go('/routines');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
