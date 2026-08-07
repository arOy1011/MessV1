import 'package:supabase_flutter/supabase_flutter.dart';

class MessService {
  MessService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static Future<Map<String, dynamic>?> getProfile(
    String userId,
  ) async {
    return await _client
        .from('profiles')
        .select('id, full_name, phone, avatar_url')
        .eq('id', userId)
        .maybeSingle();
  }

  static Future<List<Map<String, dynamic>>> getActiveMesses() async {
    final data = await _client
        .from('messes')
        .select(
          'id, name, short_name, description, timezone',
        )
        .eq('is_active', true)
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  static Future<List<Map<String, dynamic>>> getMemberTypes(
    String messId,
  ) async {
    final data = await _client
        .from('member_types')
        .select(
          'id, name, description, sort_order',
        )
        .eq('mess_id', messId)
        .eq('is_active', true)
        .order('sort_order')
        .order('name');

    return List<Map<String, dynamic>>.from(data);
  }

  static Future<Map<String, dynamic>?> getMessMembership(
    String userId,
  ) async {
    return await _client
        .from('mess_memberships')
        .select(
          '''
          id,
          mess_id,
          user_id,
          member_type_id,
          student_id,
          batch_year,
          status,
          joined_at,
          approved_at,
          deactivated_at
          ''',
        )
        .eq('user_id', userId)
        .maybeSingle();
  }

  static Future<void> createMembership({
    required String messId,
    required String userId,
    required String memberTypeId,
    required String studentId,
    required int batchYear,
  }) async {
    await _client.from('mess_memberships').insert({
      'mess_id': messId,
      'user_id': userId,
      'member_type_id': memberTypeId,
      'student_id': studentId.trim(),
      'batch_year': batchYear,
      'status': 'pending',
    });
  }

  static Future<Map<String, dynamic>?> getActiveManagerAssignment({
    required String userId,
    required String messMonthId,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    return await _client
        .from('manager_assignments')
        .select(
          'id, mess_month_id, user_id, starts_on, ends_on',
        )
        .eq('user_id', userId)
        .eq('mess_month_id', messMonthId)
        .lte('starts_on', today)
        .gte('ends_on', today)
        .maybeSingle();
  }

  static Future<List<Map<String, dynamic>>> getGovernanceRoles({
    required String userId,
    required String messId,
  }) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    final data = await _client
        .from('governance_assignments')
        .select(
          'id, role, starts_on, ends_on',
        )
        .eq('user_id', userId)
        .eq('mess_id', messId)
        .lte('starts_on', today)
        .or('ends_on.is.null,ends_on.gte.$today');

    return List<Map<String, dynamic>>.from(data);
  }

  static Future<Map<String, dynamic>?> getCurrentMessMonth(
    String messId,
  ) async {
    final now = DateTime.now();

    return await _client
        .from('mess_months')
        .select()
        .eq('mess_id', messId)
        .eq('year', now.year)
        .eq('month', now.month)
        .maybeSingle();
  }
}