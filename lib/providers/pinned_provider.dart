// lib/providers/pinned_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/task_model.dart';
import '../models/milestone_model.dart';
import 'project_provider.dart'; // Project is defined here

class PinnedProvider with ChangeNotifier {
  List<TaskModel> _pinnedTasks = [];
  List<Project> _pinnedProjects = [];
  List<MilestoneModel> _pinnedMilestones = [];
  bool _isLoading = false;

  List<TaskModel> get pinnedTasks => _pinnedTasks;
  List<Project> get pinnedProjects => _pinnedProjects;
  List<MilestoneModel> get pinnedMilestones => _pinnedMilestones;
  bool get isLoading => _isLoading;

  int get totalPinnedCount => _pinnedTasks.length + _pinnedProjects.length + _pinnedMilestones.length;

  PinnedProvider() {
    fetchPinnedItems();
  }

  Future<void> fetchPinnedItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      final Map<String, dynamic> data = await ApiService.get("/pinned");
      
      _pinnedTasks = (data['tasks'] as List).map((e) => TaskModel.fromMap(e)).toList();
      _pinnedProjects = (data['projects'] as List).map((e) => Project.fromMap(e)).toList();
      _pinnedMilestones = (data['milestones'] as List).map((e) => MilestoneModel.fromMap(e)).toList();
      
    } catch (e) {
      debugPrint("Error fetching pinned items: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to refresh everything
  void refresh() {
    fetchPinnedItems();
  }
}
