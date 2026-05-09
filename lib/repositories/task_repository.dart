// lib/repositories/task_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createTask(TaskModel task) async {
    await _client.from('tasks').insert(task.toMap());
    
    // Logic for auto-creating reminders can go here or in a DB trigger
    // Since we want interconnectedness, we'll ensure any 'urgent' task also creates a notification
    if (task.priority == TaskPriority.high || task.priority == TaskPriority.critical) {
      await _client.from('notifications').insert({
        'user_id': _client.auth.currentUser?.id,
        'title': 'High Priority Task Created',
        'content': 'New high priority task: ${task.title}',
        'type': 'task_alert'
      });
    }
  }

  Future<void> updateTaskStatus(String id, String status) async {
    await _client.from('tasks').update({'status': status}).eq('id', id);
    
    // Note: Project progress is handled by the DB trigger update_project_progress() 
    // which I already added to the schema.
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }

  Future<void> togglePin(String id, bool isPinned) async {
    await _client.from('tasks').update({'is_pinned': isPinned}).eq('id', id);
  }

  // AI-Driven Task Planning
  Future<List<Map<String, dynamic>>> getTaskSummaryForAi() async {
    return await _client.from('tasks').select('title, status, priority, due_date').limit(50);
  }
}
