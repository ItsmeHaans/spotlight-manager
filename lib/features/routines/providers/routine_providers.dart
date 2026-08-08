// features/routines/providers/routine_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/routine_service.dart';
import 'routine_filter_provider.dart';
import 'routine_display_filter_provider.dart';
import '../models/routine.dart';

final routineServiceProvider = Provider((ref) => RoutineService());

final routineListProvider = FutureProvider<List<Routine>>((ref) async {
  final selectedDate = ref.watch(routineDateFilterProvider).selectedDate;
  final display = ref.watch(routineDisplayFilterProvider);

  final all = await ref
      .watch(routineServiceProvider)
      .fetchRoutines(includeInactive: display.showInactive);

  return all.where((routine) {
    if (display.trackingType != null &&
        routine.trackingType != display.trackingType) {
      return false;
    }
    return routine.matchesDate(selectedDate);
  }).toList();
});
