import 'package:reflect/models/life_entity_model.dart';
import 'package:reflect/models/reflection_model.dart';
import 'package:reflect/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

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

  Future<UserModel> getCurrentUser() async {
    final row = await _client.from('users').select().eq('id', _userId).single();
    return UserModel.fromJson(row);
  }

  Future<List<LifeEntity>> getLifeEntity({String? type}) async {
    var query = _client.from('life_entities').select().eq('user_id', _userId);
    if (type != null) query = query.eq('entity_type', type);
    final rows = await query.order('created_at', ascending: false);
    return (rows as List).map((r) => LifeEntity.fromJson(r)).toList();
  }

  Future<List<ReflectionModel>> getTodayReflections() async {
    final startOfDay = DateTime.now().toUtc().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      microsecond: 0,
    );
    final rows = await _client
        .from('reflections')
        .select()
        .eq('user_id', _userId)
        .gte('recorded_at', startOfDay.toIso8601String())
        .order('recorded_at', ascending: false);
    return (rows as List).map((r) => ReflectionModel.fromJson(r)).toList();
  }

  Future<List<ReflectionModel>> getAllRefelctions() async {
    final rows = await _client
        .from('reflections')
        .select()
        .eq('user_id', _userId)
        .order('recorded_at', ascending: false);
    return (rows as List).map((r) => ReflectionModel.fromJson(r)).toList();
  }

  Future<void> signOut() => _client.auth.signOut();
}
