// features/routines/services/routine_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/routine.dart';

class RoutineService {
  final _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('No authenticated user');
    return id;
  }

  Future<List<Routine>> fetchRoutines({required bool includeInactive}) async {
    var query = _client.from('routines').select().eq('user_id', _userId);

    if (!includeInactive) {
      query = query.eq('is_active', true);
    }

    final response = await query.order('created_at');
    return (response as List)
        .map((row) => Routine.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addRoutine(Routine routine) async {
    await _client.from('routines').insert({
      ...routine.toMap(),
      'user_id': _userId,
    });
  }

  Future<void> updateRoutine(String id, Routine routine) async {
    await _client.from('routines').update(routine.toMap()).eq('id', id);
  }

  Future<void> deleteRoutine(String id) async {
    // hapus logs dulu biar gak kena foreign key constraint
    await _client.from('routine_logs').delete().eq('routine_id', id);
    await _client.from('routines').delete().eq('id', id);
  }

  Future<void> logProgress(String routineId, DateTime date, int value) async {
    final dateStr = date.toIso8601String().split('T').first; // 'YYYY-MM-DD'

    // cek udah ada log di tanggal itu belum (upsert manual, karena
    // routine_logs gak punya unique constraint di (routine_id, date))
    final existing = await _client
        .from('routine_logs')
        .select('id')
        .eq('routine_id', routineId)
        .eq('user_id', _userId)
        .eq('date', dateStr)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('routine_logs')
          .update({'value': value})
          .eq('id', existing['id']);
    } else {
      await _client.from('routine_logs').insert({
        'user_id': _userId,
        'routine_id': routineId,
        'date': dateStr,
        'value': value,
      });
    }
  }
}
