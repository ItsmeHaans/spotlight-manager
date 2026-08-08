// features/routines/providers/routine_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoutineDateState {
  final DateTime selectedDate;
  final DateTime
  rangeStart; // phone: Sunday minggu ini | desktop: custom "from"
  final DateTime rangeEnd; // phone: Saturday minggu ini | desktop: custom "to"

  const RoutineDateState({
    required this.selectedDate,
    required this.rangeStart,
    required this.rangeEnd,
  });
}

DateTime _sundayOf(DateTime date) {
  final diff = date.weekday % 7; // Sun=0 ... Sat=6
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: diff));
}

class RoutineDateNotifier extends Notifier<RoutineDateState> {
  @override
  RoutineDateState build() {
    final today = DateTime.now();
    final sunday = _sundayOf(today);
    return RoutineDateState(
      selectedDate: today,
      rangeStart: sunday,
      rangeEnd: sunday.add(const Duration(days: 6)),
    );
  }

  void selectDate(DateTime date) {
    state = RoutineDateState(
      selectedDate: date,
      rangeStart: state.rangeStart,
      rangeEnd: state.rangeEnd,
    );
  }

  // ---- Phone: geser per minggu, selalu Sun-Sat penuh ----
  void changeWeek(int offsetWeeks) {
    final newStart = state.rangeStart.add(Duration(days: 7 * offsetWeeks));
    state = RoutineDateState(
      selectedDate: newStart,
      rangeStart: newStart,
      rangeEnd: newStart.add(const Duration(days: 6)),
    );
  }

  // ---- Desktop: custom range bebas ----
  void setCustomRange(DateTime start, DateTime end) {
    final normalizedEnd = end.isBefore(start) ? start : end;
    state = RoutineDateState(
      selectedDate: start,
      rangeStart: DateTime(start.year, start.month, start.day),
      rangeEnd: DateTime(
        normalizedEnd.year,
        normalizedEnd.month,
        normalizedEnd.day,
      ),
    );
  }

  void resetToToday() {
    final today = DateTime.now();
    final sunday = _sundayOf(today);
    state = RoutineDateState(
      selectedDate: today,
      rangeStart: sunday,
      rangeEnd: sunday.add(const Duration(days: 6)),
    );
  }
}

final routineDateFilterProvider =
    NotifierProvider<RoutineDateNotifier, RoutineDateState>(
      RoutineDateNotifier.new,
    );
