// lib/providers/decision_log_provider.dart

import 'package:flutter/foundation.dart';
import '../models/decision_log_model.dart';
import '../services/api_service.dart';

class DecisionLogProvider with ChangeNotifier {
  List<DecisionModel> _decisions = [];
  bool _isLoading = false;

  List<DecisionModel> get decisions => _decisions..sort((a, b) => b.date.compareTo(a.date));
  bool get isLoading => _isLoading;

  DecisionLogProvider() {
    fetchDecisions();
  }

  Future<void> fetchDecisions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await ApiService.get("/decision-log");
      _decisions = data.map((item) => DecisionModel.fromMap(item)).toList();
    } catch (e) {
      debugPrint("Error fetching decisions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDecision(DecisionModel decision) async {
    try {
      final data = await ApiService.post("/decision-log", decision.toMap());
      _decisions.add(DecisionModel.fromMap(data));
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding decision: $e");
    }
  }
}
