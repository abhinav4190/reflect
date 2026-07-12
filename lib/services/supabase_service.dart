import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<void> ensureUserRow() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return;

    final existing = await _client
        .from('users')
        .select('id')
        .eq('id', authUser.id)
        .maybeSingle();

    if (existing == null) {
      await _client.from('users').insert({
        'id': authUser.id,
        'email': authUser.email ?? '',
      });
    }
  }

  Future<bool> isSetupCompleted() async {
    final authUser = _client.auth.currentUser;

    if (authUser == null) return false;

    final row = await _client
        .from('users')
        .select('setup_completed')
        .eq('id', authUser.id)
        .maybeSingle();

    return row?['setup_completed'] == true;
  }
}
