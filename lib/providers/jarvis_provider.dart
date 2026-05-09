// lib/providers/jarvis_provider.dart

import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/milestone_model.dart';
import '../services/ai_service.dart';
import 'task_provider.dart';
import 'milestone_provider.dart';
import 'risk_provider.dart';
import 'planner_provider.dart';
import 'reminder_provider.dart';

class JarvisProvider with ChangeNotifier {
  final TaskProvider? taskProvider;
  final MilestoneProvider? milestoneProvider;
  final RiskProvider? riskProvider;
  final PlannerProvider? plannerProvider;
  final ReminderProvider? reminderProvider;

  final AiService _aiService = AiService();
  final List<String> _history = [];
  bool _isProcessing = false;
  int _navigationIndex = 0;

  bool get isProcessing => _isProcessing;
  int get navigationIndex => _navigationIndex;
  List<String> get history => _history;

  JarvisProvider({
    this.taskProvider,
    this.milestoneProvider,
    this.riskProvider,
    this.plannerProvider,
    this.reminderProvider,
  });

  Future<void> processCommand(String command) async {
    if (command.trim().isEmpty) return;
    
    _isProcessing = true;
    _history.add("User: $command");
    notifyListeners();

    try {
      final Map<String, dynamic> parsed = await _aiService.parseCommand(command);
      final String action = parsed['action'] ?? 'chat';
      
      String responseMessage = "";

      switch (action) {
        case 'create_task':
          final task = TaskModel(
            id: '',
            title: parsed['title'] ?? 'New Task',
            priority: _parsePriority(parsed['priority'] ?? 'medium'),
            status: TaskStatus.todo,
          );
          await taskProvider?.addTask(task);
          responseMessage = "Task created: ${task.title}";
          break;
          
        case 'set_reminder':
          final time = parsed['due_date'] != null 
              ? DateTime.parse(parsed['due_date']) 
              : DateTime.now().add(const Duration(hours: 1));
          await reminderProvider?.addReminder(parsed['title'] ?? 'Reminder', time);
          responseMessage = "Reminder set for ${time.hour}:${time.minute}";
          break;

        default:
          responseMessage = await _aiService.getJarvisResponse(command, "General AI interaction");
      }

      _history.add("JARVIS: $responseMessage");
    } catch (e) {
      _history.add("JARVIS: Error processing neural link. ($e)");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  TaskPriority _parsePriority(String priorityStr) {
    switch (priorityStr.toLowerCase()) {
      case 'critical': return TaskPriority.critical;
      case 'high': return TaskPriority.high;
      case 'low': return TaskPriority.low;
      default: return TaskPriority.medium;
    }
  }

  void setNavigationIndex(int index) {
    _navigationIndex = index;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
