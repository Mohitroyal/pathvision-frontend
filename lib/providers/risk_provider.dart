// lib/providers/risk_provider.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/risk_model.dart';
import '../realtime/realtime_service.dart';

class RiskProvider with ChangeNotifier {
  final RealtimeService _realtime = RealtimeService();
  final SupabaseClient _client = Supabase.instance.client;
  
  List<RiskModel> _risks = [];
  bool _isLoading = false;

  List<RiskModel> get risks => List.unmodifiable(_risks);
  bool get isLoading => _isLoading;

  int get criticalCount => _risks.where((r) => r.severity == RiskSeverity.critical).length;
  int get overdueCount => _risks.where((r) => r.severity == RiskSeverity.overdue).length;
  int get monitorCount => _risks.where((r) => r.severity == RiskSeverity.monitor).length;
  int get planCount => _risks.where((r) => r.severity == RiskSeverity.plan).length;

  RiskProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();
    
    _realtime.riskStream.listen((data) {
      _risks = data.map((item) => RiskModel.fromMap(item)).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Neural Risk Sync Error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addRisk({
    required String title,
    required String description,
    required RiskSeverity severity,
    List<String> tags = const [],
    String? owner,
  }) async {
    final newRisk = RiskModel(
      id: '',
      title: title.trim(),
      description: description.trim(),
      severity: severity,
      tags: tags,
      owner: owner,
    );

    try {
      await _client.from('risks').insert(newRisk.toMap());
    } catch (e) {
      debugPrint("Error adding risk: $e");
    }
  }

  Future<void> updateRisk(
    String id, {
    String? title,
    String? description,
    RiskSeverity? severity,
    List<String>? tags,
    String? owner,
  }) async {
    final i = _risks.indexWhere((r) => r.id == id);
    if (i == -1) return;
    try {
      final Map<String, dynamic> updates = {};
      if (title != null && title.trim().isNotEmpty) updates['title'] = title.trim();
      if (description != null) updates['description'] = description.trim();
      if (severity != null) updates['severity'] = severity.name;
      if (tags != null) updates['tags'] = tags;
      if (owner != null) updates['owner'] = owner;

      await _client.from('risks').update(updates).eq('id', id);
    } catch (e) {
      debugPrint("Error updating risk: $e");
    }
  }

  Future<void> removeRisk(String id) async {
    try {
      await _client.from('risks').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error removing risk: $e");
    }
  }

  String autoInsight() {
    if (_risks.isEmpty) return 'No active risks. System nominal.';
    final crit = criticalCount;
    final over = overdueCount;
    if (crit > 0 && over > 0) {
      return '$crit critical risk${crit > 1 ? 's' : ''} detected and $over overdue item${over > 1 ? 's' : ''}. Immediate review recommended.';
    }
    if (crit > 0) {
      final firstCrit = _risks.where((r) => r.severity == RiskSeverity.critical).toList();
      return '$crit critical risk${crit > 1 ? 's' : ''} detected. ${firstCrit.isNotEmpty ? firstCrit.first.title : "High-impact item"} requires attention.';
    }
    if (over > 0) {
      return '$over overdue item${over > 1 ? 's' : ''} on the radar. No critical escalations.';
    }
    return 'Monitoring ${_risks.length} item${_risks.length > 1 ? 's' : ''}. No critical escalations.';
  }
}
