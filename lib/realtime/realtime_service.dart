// lib/realtime/realtime_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class RealtimeService {
  final SupabaseClient client = Supabase.instance.client;
  SupabaseClient get _client => client;
  
  // Streams for each module
  Stream<List<Map<String, dynamic>>> get taskStream => _client.from('tasks').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get projectStream => _client.from('projects').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get milestoneStream => _client.from('milestones').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get riskStream => _client.from('risks').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get financeStream => _client.from('finance_transactions').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get goalStream => _client.from('goals').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get reminderStream => _client.from('reminders').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get plannerStream => _client.from('planner_blocks').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get notificationStream => _client.from('notifications').stream(primaryKey: ['id']);
  Stream<List<Map<String, dynamic>>> get brainDumpStream => _client.from('brain_dump').stream(primaryKey: ['id']);

  void initializeRealtime() {
    // This can be used to set up global broadcast channels if needed
    print("Neural Real-time Link Established.");
  }
}
