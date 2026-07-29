import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/routine.dart';

class RoutineService {
  final _client = Supabase.instance.client;

  Future<List<Routine>> fetchRoutines() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _client
        .from('routines')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (response as List).map((row) => Routine.fromMap(row)).toList();
  }

  Future<void> addRoutine(
    String title,
    String trackingType,
    int? targetCount,
  ) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('routines').insert({
      'user_id': userId,
      'title': title,
      'tracking_type': trackingType,
      'target_count': targetCount,
    });
  }
}
