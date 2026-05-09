// lib/providers/reminder_provider.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';
import '../realtime/realtime_service.dart';

class Reminder {
  final String id;
  final String? taskId;
  final String message;
  final DateTime remindAt;
  final bool isSent;

  Reminder({
    required this.id,
    this.taskId,
    required this.message,
    required this.remindAt,
    this.isSent = false,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'].toString(),
      taskId: map['task_id']?.toString(),
      message: map['title'] ?? map['message'] ?? 'Untitled Reminder',
      remindAt: DateTime.parse(map['reminder_time'] ?? map['remind_at']),
      isSent: map['is_completed'] ?? map['is_sent'] ?? false,
    );
  }
}

class ReminderProvider with ChangeNotifier {
  final RealtimeService _realtime = RealtimeService();
  final SupabaseClient _client = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();
  
  List<Reminder> _reminders = [];
  bool _isLoading = false;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  ReminderProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();
    
    _realtime.reminderStream.listen((data) {
      _reminders = data.map((item) => Reminder.fromMap(item)).toList();
      _isLoading = false;
      
      // Schedule notifications for future reminders
      for (var reminder in _reminders) {
        if (!reminder.isSent && reminder.remindAt.isAfter(DateTime.now())) {
          _scheduleReminderNotification(reminder);
        }
      }
      
      notifyListeners();
    }, onError: (e) {
      debugPrint("Neural Reminder Sync Error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addReminder(String message, DateTime remindAt, {String? taskId}) async {
    try {
      await _client.from('reminders').insert({
        'title': message,
        'reminder_time': remindAt.toIso8601String(),
        'task_id': taskId,
        'user_id': _client.auth.currentUser?.id,
      });
    } catch (e) {
      debugPrint("Error adding reminder: $e");
    }
  }

  void _scheduleReminderNotification(Reminder reminder) {
    _notificationService.scheduleNotification(
      id: reminder.id.hashCode,
      title: 'JARVIS Reminder',
      body: reminder.message,
      scheduledTime: reminder.remindAt,
    );
  }

  Future<void> removeReminder(String id) async {
    try {
      await _client.from('reminders').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error removing reminder: $e");
    }
  }
}
