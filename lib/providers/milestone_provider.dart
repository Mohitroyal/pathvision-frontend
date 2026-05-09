// lib/providers/milestone_provider.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/milestone_model.dart';
import '../realtime/realtime_service.dart';

class MilestoneProvider with ChangeNotifier {
  final RealtimeService _realtime = RealtimeService();
  final SupabaseClient _client = Supabase.instance.client;

  final DateTime timelineStart = DateTime(2026, 4, 1);
  final DateTime timelineEnd = DateTime(2026, 9, 30);

  List<MilestoneModel> _milestones = [];
  List<GoalModel> _goals = [];
  List<CohortModel> _cohorts = [];
  bool _isLoading = false;

  List<MilestoneModel> get milestones => List.unmodifiable(_milestones);
  List<GoalModel> get goals => List.unmodifiable(_goals);
  List<CohortModel> get cohorts => List.unmodifiable(_cohorts);
  bool get isLoading => _isLoading;

  List<String> get projects => _milestones.map((m) => m.project).toSet().toList();

  bool get imasAtRisk => _milestones.any(
        (m) => m.project == 'IMAS Core System' && m.status == MilestoneStatus.atRisk,
      );

  List<MilestoneModel> milestonesForProject(String project) =>
      _milestones.where((m) => m.project == project).toList();

  MilestoneProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();
    
    _realtime.milestoneStream.listen((data) {
      _milestones = data.map((item) => MilestoneModel.fromMap(item)).toList();
      _isLoading = false;
      notifyListeners();
    });

    _realtime.goalStream.listen((data) {
      _goals = data.map((item) => GoalModel.fromMap(item)).toList();
      notifyListeners();
    });

    // Note: If 'cohorts' table exists in future expansion
    _client.from('cohorts').stream(primaryKey: ['id']).listen((data) {
      _cohorts = data.map((item) => CohortModel.fromMap(item)).toList();
      notifyListeners();
    }, onError: (e) => debugPrint("Cohort Stream Error: $e"));
  }

  Future<void> addMilestone({
    required String title,
    required String project,
    required DateTime start,
    required DateTime end,
    MilestoneStatus status = MilestoneStatus.planned,
  }) async {
    final newM = MilestoneModel(
      id: '',
      title: title,
      project: project,
      start: start,
      end: end,
      status: status,
    );

    try {
      await _client.from('milestones').insert(newM.toMap());
    } catch (e) {
      debugPrint("Error adding milestone: $e");
    }
  }

  Future<void> updateMilestoneStatus(String id, MilestoneStatus status) async {
    try {
      await _client.from('milestones').update({'status': status.name}).eq('id', id);
    } catch (e) {
      debugPrint("Error updating milestone: $e");
    }
  }

  Future<void> removeMilestone(String id) async {
    try {
      await _client.from('milestones').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error removing milestone: $e");
    }
  }

  Future<void> togglePin(String id) async {
    final i = _milestones.indexWhere((m) => m.id == id);
    if (i == -1) return;
    try {
      final newPinnedStatus = !_milestones[i].isPinned;
      await _client.from('milestones').update({'is_pinned': newPinnedStatus}).eq('id', id);
    } catch (e) {
      debugPrint("Error toggling milestone pin: $e");
    }
  }

  Future<void> addCohort({
    required String name,
    required DateTime start,
    required DateTime end,
    CohortStatus status = CohortStatus.planned,
    List<String> memberInitials = const [],
  }) async {
    try {
      await _client.from('cohorts').insert({
        'name': name,
        'start_date': start.toIso8601String(),
        'end_date': end.toIso8601String(),
        'status': status.name,
        'members': memberInitials,
      });
    } catch (e) {
      debugPrint("Error adding cohort: $e");
    }
  }

  Future<void> updateGoalProgress(String id, double progress) async {
    try {
      await _client.from('goals').update({'current_value': progress * 100}).eq('id', id);
    } catch (e) {
      debugPrint("Error updating goal: $e");
    }
  }
}
