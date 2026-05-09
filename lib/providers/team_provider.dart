import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/api_service.dart';

class TeamProvider with ChangeNotifier {
  List<MemberModel> _members = [];
  bool _isLoading = false;

  List<MemberModel> get members => _members;
  bool get isLoading => _isLoading;

  TeamProvider() {
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await ApiService.get("/users");
      _members = data.map((item) => MemberModel.fromMap(item)).toList();
    } catch (e) {
      debugPrint("Error fetching members: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMember(MemberModel member) async {
    try {
      final data = await ApiService.post("/users", member.toMap());
      final newMember = MemberModel.fromMap(data);
      _members.add(newMember);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding member: $e");
    }
  }

  Future<void> removeMember(String id) async {
    try {
      await ApiService.delete("/users/$id");
      _members.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error removing member: $e");
    }
  }

  Future<void> updateMember(MemberModel member) async {
    try {
      final data = await ApiService.put("/users/${member.id}", member.toMap());
      final updatedMember = MemberModel.fromMap(data);
      final index = _members.indexWhere((m) => m.id == member.id);
      if (index != -1) {
        _members[index] = updatedMember;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating member: $e");
    }
  }
}
