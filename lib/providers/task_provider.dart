// lib/providers/task_provider.dart

import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../realtime/realtime_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  final RealtimeService _realtime = RealtimeService();
  
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<TaskModel> get backlogTasks => _tasks.where((t) => t.status == TaskStatus.backlog).toList();
  List<TaskModel> get todoTasks => _tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<TaskModel> get inProgressTasks => _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<TaskModel> get doneTasks => _tasks.where((t) => t.status == TaskStatus.done).toList();

  TaskProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();
    
    _realtime.taskStream.listen((data) {
      _tasks = data.map((item) => TaskModel.fromMap(item)).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Neural Task Sync Error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addTask(TaskModel task) async {
    try {
      await _repository.createTask(task);
    } catch (e) {
      debugPrint("Error adding task: $e");
    }
  }

  Future<void> updateTaskStatus(String id, TaskStatus newStatus) async {
    try {
      await _repository.updateTaskStatus(id, newStatus.name);
    } catch (e) {
      debugPrint("Error updating task status: $e");
    }
  }

  Future<void> removeTask(String id) async {
    try {
      await _repository.deleteTask(id);
    } catch (e) {
      debugPrint("Error removing task: $e");
    }
  }

  Future<void> togglePin(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      try {
        await _repository.togglePin(id, !_tasks[index].isPinned);
      } catch (e) {
        debugPrint("Error toggling task pin: $e");
      }
    }
  }
}
