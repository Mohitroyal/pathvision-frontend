// lib/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Generic CRUD
  static Future<List<Map<String, dynamic>>> get(String table) async {
    final response = await client.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> post(String table, Map<String, dynamic> data) async {
    final response = await client.from(table).insert(data).select().single();
    return response;
  }

  static Future<Map<String, dynamic>> update(String table, String id, Map<String, dynamic> data) async {
    final response = await client.from(table).update(data).eq('id', id).select().single();
    return response;
  }

  static Future<void> delete(String table, String id) async {
    await client.from(table).delete().eq('id', id);
  }

  // Realtime Stream
  static Stream<List<Map<String, dynamic>>> stream(String table) {
    return client.from(table).stream(primaryKey: ['id']);
  }
}
