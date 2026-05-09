// lib/models/milestone_model.dart

enum MilestoneStatus { done, inProgress, planned, planning, atRisk }

extension MilestoneStatusX on MilestoneStatus {
  String get label {
    switch (this) {
      case MilestoneStatus.done:
        return 'DONE';
      case MilestoneStatus.inProgress:
        return 'IN PROGRESS';
      case MilestoneStatus.planned:
        return 'PLANNED';
      case MilestoneStatus.planning:
        return 'PLANNING';
      case MilestoneStatus.atRisk:
        return 'AT RISK';
    }
  }
}

enum CohortStatus { active, planned, archived }

extension CohortStatusX on CohortStatus {
  String get label {
    switch (this) {
      case CohortStatus.active:
        return 'ACTIVE';
      case CohortStatus.planned:
        return 'PLAN NEEDED';
      case CohortStatus.archived:
        return 'ARCHIVED';
    }
  }
}

enum GoalStatus { onTrack, atRisk, planNeeded, done }

extension GoalStatusX on GoalStatus {
  String get label {
    switch (this) {
      case GoalStatus.onTrack:
        return 'ON TRACK';
      case GoalStatus.atRisk:
        return 'AT RISK';
      case GoalStatus.planNeeded:
        return 'PLAN NEEDED';
      case GoalStatus.done:
        return 'DONE';
    }
  }
}

class MilestoneModel {
  final String id;
  String title;
  String project;
  DateTime start;
  DateTime end;
  MilestoneStatus status;
  bool isPinned;

  MilestoneModel({
    required this.id,
    required this.title,
    required this.project,
    required this.start,
    required this.end,
    this.status = MilestoneStatus.planned,
    this.isPinned = false,
  });

  factory MilestoneModel.fromMap(Map<String, dynamic> map) {
    return MilestoneModel(
      id: map['id'].toString(),
      title: map['title'],
      project: map['project_name'] ?? 'General',
      start: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      end: map['due_date'] != null ? DateTime.parse(map['due_date']) : DateTime.now().add(const Duration(days: 30)),
      status: map['is_completed'] == true ? MilestoneStatus.done : MilestoneStatus.inProgress,
      isPinned: map['is_pinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'due_date': end.toIso8601String(),
      'is_completed': status == MilestoneStatus.done,
      'is_pinned': isPinned,
    };
  }
}

class GoalModel {
  final String id;
  String title;
  double progress; // 0.0 - 1.0
  GoalStatus status;
  String? note;

  GoalModel({
    required this.id,
    required this.title,
    required this.progress,
    this.status = GoalStatus.onTrack,
    this.note,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'].toString(),
      title: map['title'],
      progress: ((map['current_value'] ?? 0) / (map['target_value'] ?? 100)).toDouble(),
      status: map['metadata']?['status'] != null ? _statusFromString(map['metadata']['status']) : GoalStatus.onTrack,
      note: map['description'],
    );
  }

  static GoalStatus _statusFromString(String? status) {
    switch (status) {
      case 'atRisk': return GoalStatus.atRisk;
      case 'done': return GoalStatus.done;
      case 'planNeeded': return GoalStatus.planNeeded;
      default: return GoalStatus.onTrack;
    }
  }
}

class CohortModel {
  final String id;
  String name;
  DateTime start;
  DateTime end;
  CohortStatus status;
  List<String> memberInitials;

  CohortModel({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    this.status = CohortStatus.active,
    this.memberInitials = const [],
  });

  factory CohortModel.fromMap(Map<String, dynamic> map) {
    return CohortModel(
      id: map['id'].toString(),
      name: map['name'],
      start: DateTime.parse(map['created_at']),
      end: DateTime.now().add(const Duration(days: 90)), // Placeholder
      status: CohortStatus.active,
      memberInitials: [],
    );
  }
}
