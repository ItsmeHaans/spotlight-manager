import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

enum FilterType { singleDate, dateRange, category } // your own design — describes what kind of filter a page needs

class FilterConfig {
  final FilterType type;
  final List<String>? categoryOptions; // only used when type == category
  const FilterConfig({required this.type, this.categoryOptions});
}

Future<dynamic> showFilterSheet(BuildContext context, AppColors colors, FilterConfig config) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: colors.background,
    builder: (context) {
      switch (config.type) {
        case FilterType.category:
          return _CategoryFilterSheet(colors: colors, options: config.categoryOptions!);
        case FilterType.singleDate:
          return _SingleDateFilterSheet(colors: colors);
        case FilterType.dateRange:
          return _DateRangeFilterSheet(colors: colors);
      }
    },
  );
}

class _CategoryFilterSheet extends StatelessWidget {
  final AppColors colors;
  final List<String> options;
  const _CategoryFilterSheet({required this.colors, required this.options});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Wrap( // native Flutter — like Row, but wraps to a new line if it runs out of space
        spacing: AppSpacing.sm,
        children: options.map((opt) {
          return ChoiceChip( // native Flutter — a tappable, selectable pill
            label: Text(opt),
            selected: false, // wire to real state once you build this out
            onSelected: (_) => Navigator.pop(context, opt),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleDateFilterSheet extends StatelessWidget {
  final AppColors colors;
  const _SingleDateFilterSheet({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text("Date picker placeholder — circle date list comes later",
          style: AppTypography.body.copyWith(color: colors.textPrimary)),
    );
  }
}

class _DateRangeFilterSheet extends StatelessWidget {
  final AppColors colors;
  const _DateRangeFilterSheet({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ElevatedButton(
        onPressed: () async {
          final range = await showDateRangePicker( // native Flutter — built-in date range UI
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (range != null && context.mounted) Navigator.pop(context, range);
        },
        child: const Text("Pick date range"),
      ),
    );
  }
}