import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  Map<String, dynamic> _data = {};
  bool _isLoading = false;

  Map<String, dynamic> get data => _data;
  bool get isLoading => _isLoading;

  DashboardProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _data = await ApiService.get("/dashboard");
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
