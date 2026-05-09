import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../realtime/realtime_service.dart';

enum BlockType { focus, meeting, task, overdue }

class PlannerBlock {
  final String id;
  final String title;
  final int startHour;
  final int duration;
  final BlockType type;
  final String? notes;
  final bool isOverdue;

  PlannerBlock({
    required this.id,
    required this.title,
    required this.startHour,
    this.duration = 1,
    this.type = BlockType.task,
    this.notes,
    this.isOverdue = false,
  });

  PlannerBlock copyWith({
    int? startHour,
    int? duration,
    String? notes,
  }) {
    return PlannerBlock(
      id: id,
      title: title,
      startHour: startHour ?? this.startHour,
      duration: duration ?? this.duration,
      type: type,
      notes: notes ?? this.notes,
      isOverdue: isOverdue,
    );
  }

  factory PlannerBlock.fromMap(Map<String, dynamic> map) {
    final startTime = DateTime.parse(map['start_time']);
    final endTime = DateTime.parse(map['end_time']);
    final meta = map['metadata'] ?? {};
    return PlannerBlock(
      id: map['id'],
      title: map['title'] ?? 'Untitled Block',
      startHour: startTime.hour,
      duration: (endTime.hour - startTime.hour).clamp(1, 24),
      type: _typeFromString(meta['type']),
      notes: meta['notes'],
      isOverdue: meta['is_overdue'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day, startHour);
    final end = start.add(Duration(hours: duration > 0 ? duration : 1));
    
    return {
      'title': title,
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
      'metadata': {
        'type': type.name,
        'notes': notes,
        'is_overdue': isOverdue,
      }
    };
  }

  static BlockType _typeFromString(String? type) {
    switch (type) {
      case 'focus': return BlockType.focus;
      case 'meeting': return BlockType.meeting;
      case 'overdue': return BlockType.overdue;
      default: return BlockType.task;
    }
  }
}

class PlannerProvider with ChangeNotifier {
  final RealtimeService _realtime = RealtimeService();
  final SupabaseClient _client = Supabase.instance.client;
  
  List<PlannerBlock> _blocks = [];
  bool _isLoading = false;

  List<PlannerBlock> get blocks => _blocks;
  bool get isLoading => _isLoading;

  PlannerProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    _isLoading = true;
    notifyListeners();
    
    _realtime.plannerStream.listen((data) {
      _blocks = data.map((item) => PlannerBlock.fromMap(item)).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Neural Planner Sync Error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addBlock(PlannerBlock block) async {
    try {
      await _client.from('planner_blocks').insert(block.toMap());
    } catch (e) {
      debugPrint("Error adding planner block: $e");
    }
  }

  Future<void> updateBlock(String id, {int? startHour, int? duration, String? notes}) async {
    final index = _blocks.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updated = _blocks[index].copyWith(
        startHour: startHour,
        duration: duration,
        notes: notes,
      );
      try {
        await _client.from('planner_blocks').update(updated.toMap()).eq('id', id);
      } catch (e) {
        debugPrint("Error updating planner block: $e");
      }
    }
  }

  Future<void> removeBlock(String id) async {
    try {
      await _client.from('planner_blocks').delete().eq('id', id);
    } catch (e) {
      debugPrint("Error removing planner block: $e");
    }
  }
}
