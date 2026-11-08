import 'package:supabase_flutter/supabase_flutter.dart';

class HealthRecordService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRecords(
    String recordType,
  ) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final response = await _supabase
        .from('health_records')
        .select()
        .eq('user_id', user.id)
        .eq('record_type', recordType)
        .order('recorded_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}