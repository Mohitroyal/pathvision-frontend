import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/supabase_service.dart';

class GoalProvider with ChangeNotifier {
  List<GoalModel> _goals = [];
  bool _isLoading = false;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  GoalProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();

    SupabaseService.stream('goals').listen((data) {
      _goals = data.map((item) => GoalModel.fromMap(item)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addGoal(GoalModel goal) async {
    try {
      await SupabaseService.post('goals', goal.toMap());
    } catch (e) {
      debugPrint("Error adding goal: $e");
    }
  }
}
