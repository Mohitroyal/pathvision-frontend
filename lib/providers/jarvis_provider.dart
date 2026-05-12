// lib/providers/jarvis_provider.dart

import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/milestone_model.dart';
import '../models/jarvis_action_model.dart';
import '../services/ai_service.dart';
import '../services/jarvis_system.dart';
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
  final List<JarvisExecutionResult> _history = [];
  bool _isProcessing = false;
  int _navigationIndex = 0;

  bool get isProcessing => _isProcessing;
  int get navigationIndex => _navigationIndex;
  List<JarvisExecutionResult> get history => _history;

  JarvisProvider({
    this.taskProvider,
    this.milestoneProvider,
    this.riskProvider,
    this.plannerProvider,
    this.reminderProvider,
  });

  Future<void> executeActions(JarvisExecutionResult result) async {
    _isProcessing = true;
    _history.insert(0, result);
    notifyListeners();

    try {
      for (final action in result.actions) {
        switch (action.type) {
          case JarvisActionType.createTask:
            final task = TaskModel(
              id: '',
              title: action.data['title'] ?? 'New Task',
              priority: _parsePriority(action.data['priority'] ?? 'medium'),
              status: TaskStatus.todo,
            );
            await taskProvider?.addTask(task);
            break;
          case JarvisActionType.createReminder:
            final time = action.data['due_date'] != null 
                ? DateTime.parse(action.data['due_date']) 
                : DateTime.now().add(const Duration(hours: 1));
            await reminderProvider?.addReminder(action.data['title'] ?? 'Reminder', time);
            break;
          case JarvisActionType.updateMilestone:
            // Implementation...
            break;
          default:
            break;
        }
      }
    } catch (e) {
      debugPrint("JARVIS Execution Error: $e");
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> processCommand(String command) async {
    if (command.trim().isEmpty) return;
    
    _isProcessing = true;
    notifyListeners();

    try {
      final result = JarvisSystem.parseInput(command);
      _history.insert(0, result);
      
      if (result.success) {
        await executeActions(result);
      }
    } catch (e) {
      debugPrint("Neural Link Error: $e");
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
