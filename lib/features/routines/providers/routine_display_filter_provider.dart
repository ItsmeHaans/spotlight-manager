// features/routines/providers/routine_display_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoutineDisplayFilter {
  final bool showInactive;
  final String? trackingType; // null = All, 'checklist', 'counter'

  const RoutineDisplayFilter({this.showInactive = false, this.trackingType});

  RoutineDisplayFilter copyWith({
    bool? showInactive,
    String? trackingType,
    bool clearType = false,
  }) {
    return RoutineDisplayFilter(
      showInactive: showInactive ?? this.showInactive,
      trackingType: clearType ? null : (trackingType ?? this.trackingType),
    );
  }
}

class RoutineDisplayFilterNotifier extends Notifier<RoutineDisplayFilter> {
  @override
  RoutineDisplayFilter build() => const RoutineDisplayFilter();

  void toggleShowInactive(bool value) =>
      state = state.copyWith(showInactive: value);

  void setTrackingType(String? type) => state = type == null
      ? state.copyWith(clearType: true)
      : state.copyWith(trackingType: type);
}

final routineDisplayFilterProvider =
    NotifierProvider<RoutineDisplayFilterNotifier, RoutineDisplayFilter>(
      RoutineDisplayFilterNotifier.new,
    );
