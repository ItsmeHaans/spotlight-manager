// features/routines/models/routine.dart
class Routine {
  final String id;
  final String title;
  final String trackingType; // 'checklist' | 'counter'
  final int? targetCount;
  final String
  frequency; // 'daily' | 'weekdays' | 'custom_weekly' | 'custom_monthly'
  final List<int>? frequencyDetail; // lihat penjelasan di atas
  final String? time;
  final bool isActive;

  Routine({
    required this.id,
    required this.title,
    required this.trackingType,
    this.targetCount,
    required this.frequency,
    this.frequencyDetail,
    this.time,
    required this.isActive,
  });

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'],
      title: map['title'],
      trackingType: map['tracking_type'] ?? 'checklist',
      targetCount: map['target_count'],
      frequency: map['frequency'] ?? 'daily',
      frequencyDetail: (map['frequency_detail'] as List?)?.cast<int>(),
      time: map['time'],
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'tracking_type': trackingType,
      'target_count': targetCount,
      'frequency': frequency,
      'frequency_detail': frequencyDetail,
      'time': time,
      'is_active': isActive,
    };
  }

  /// Cek apakah routine ini terjadwal untuk tanggal tertentu.
  bool matchesDate(DateTime date) {
    switch (frequency) {
      case 'daily':
        return true;
      case 'weekdays':
        return date.weekday >= DateTime.monday &&
            date.weekday <= DateTime.friday;
      case 'custom_weekly':
        return frequencyDetail?.contains(date.weekday) ?? false;
      case 'custom_monthly':
        return frequencyDetail?.contains(date.day) ?? false;
      default:
        return false;
    }
  }
}
