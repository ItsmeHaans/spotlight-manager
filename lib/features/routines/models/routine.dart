class Routine {
  final String id;
  final String title;
  final String trackingType; // 'checklist' or 'counter'
  final int? targetCount;
  final bool isActive;

  Routine({
    required this.id,
    required this.title,
    required this.trackingType,
    this.targetCount,
    required this.isActive,
  });

  factory Routine.fromMap(Map<String, dynamic> map) {
    // native Dart pattern — converts raw Supabase JSON into a real object
    return Routine(
      id: map['id'],
      title: map['title'],
      trackingType: map['tracking_type'],
      targetCount: map['target_count'],
      isActive: map['is_active'] ?? true,
    );
  }
}
