// lib/models/jarvis_action_model.dart

enum JarvisActionType {
  createTask,
  assignMember,
  scheduleBlock,
  createReminder,
  updateMilestone,
  createRisk,
  optimizeSchedule,
  convertNoteToTask,
  reassignTask,
  addDependency,
}

/// Convert JarvisActionType to string representation
String actionTypeToString(JarvisActionType type) {
  const map = {
    JarvisActionType.createTask: 'create_task',
    JarvisActionType.assignMember: 'assign_member',
    JarvisActionType.scheduleBlock: 'schedule_block',
    JarvisActionType.createReminder: 'create_reminder',
    JarvisActionType.updateMilestone: 'update_milestone',
    JarvisActionType.createRisk: 'create_risk',
    JarvisActionType.optimizeSchedule: 'optimize_schedule',
    JarvisActionType.convertNoteToTask: 'convert_note_to_task',
    JarvisActionType.reassignTask: 'reassign_task',
    JarvisActionType.addDependency: 'add_dependency',
  };
  return map[type] ?? 'unknown';
}

/// Convert string to JarvisActionType
JarvisActionType? stringToActionType(String str) {
  const map = {
    'create_task': JarvisActionType.createTask,
    'assign_member': JarvisActionType.assignMember,
    'schedule_block': JarvisActionType.scheduleBlock,
    'create_reminder': JarvisActionType.createReminder,
    'update_milestone': JarvisActionType.updateMilestone,
    'create_risk': JarvisActionType.createRisk,
    'optimize_schedule': JarvisActionType.optimizeSchedule,
    'convert_note_to_task': JarvisActionType.convertNoteToTask,
    'reassign_task': JarvisActionType.reassignTask,
    'add_dependency': JarvisActionType.addDependency,
  };
  return map[str];
}

extension JarvisActionTypeX on JarvisActionType {
  String get value => actionTypeToString(this);

  static JarvisActionType? fromString(String str) {
    return stringToActionType(str);
  }
}

class JarvisAction {
  final JarvisActionType type;
  final String module;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  JarvisAction({
    required this.type,
    required this.module,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory JarvisAction.fromJson(Map<String, dynamic> json) {
    return JarvisAction(
      type: stringToActionType(json['type'] as String) ?? JarvisActionType.createTask,
      module: json['module'] as String? ?? 'tasks',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.value,
        'module': module,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
      };
}

class JarvisPlanning {
  final List<JarvisSubtask> subtasks;
  final List<JarvisScheduleBlock> schedule;
  final List<JarvisRisk> risks;

  JarvisPlanning({
    this.subtasks = const [],
    this.schedule = const [],
    this.risks = const [],
  });

  factory JarvisPlanning.fromJson(Map<String, dynamic> json) {
    return JarvisPlanning(
      subtasks: (json['subtasks'] as List?)
              ?.map((e) => JarvisSubtask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      schedule: (json['schedule'] as List?)
              ?.map((e) => JarvisScheduleBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      risks: (json['risks'] as List?)
              ?.map((e) => JarvisRisk.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'schedule': schedule.map((s) => s.toJson()).toList(),
        'risks': risks.map((r) => r.toJson()).toList(),
      };
}

class JarvisSubtask {
  final String title;
  final String? duration;
  final int? priority;

  JarvisSubtask({required this.title, this.duration, this.priority});

  factory JarvisSubtask.fromJson(Map<String, dynamic> json) {
    return JarvisSubtask(
      title: json['title'] as String? ?? '',
      duration: json['duration'] as String?,
      priority: json['priority'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        if (duration != null) 'duration': duration,
        if (priority != null) 'priority': priority,
      };
}

class JarvisScheduleBlock {
  final String time;
  final String task;
  final String? assignee;

  JarvisScheduleBlock({required this.time, required this.task, this.assignee});

  factory JarvisScheduleBlock.fromJson(Map<String, dynamic> json) {
    return JarvisScheduleBlock(
      time: json['time'] as String? ?? '',
      task: json['task'] as String? ?? '',
      assignee: json['assignee'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'task': task,
        if (assignee != null) 'assignee': assignee,
      };
}

class JarvisRisk {
  final String type;
  final String? reason;
  final String level;

  JarvisRisk({required this.type, this.reason, required this.level});

  factory JarvisRisk.fromJson(Map<String, dynamic> json) {
    return JarvisRisk(
      type: json['type'] as String? ?? 'unknown',
      reason: json['reason'] as String?,
      level: json['level'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (reason != null) 'reason': reason,
        'level': level,
      };
}

class JarvisExecutionResult {
  final String intent;
  final List<JarvisAction> actions;
  final JarvisPlanning planning;
  final bool success;
  final String? error;
  final DateTime executedAt;

  JarvisExecutionResult({
    required this.intent,
    required this.actions,
    required this.planning,
    this.success = true,
    this.error,
    DateTime? executedAt,
  }) : executedAt = executedAt ?? DateTime.now();

  factory JarvisExecutionResult.fromJson(Map<String, dynamic> json) {
    return JarvisExecutionResult(
      intent: json['intent'] as String? ?? 'unknown',
      actions: (json['actions'] as List?)
              ?.map((e) => JarvisAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      planning: JarvisPlanning.fromJson(json['planning'] as Map<String, dynamic>? ?? {}),
      success: json['success'] as bool? ?? true,
      error: json['error'] as String?,
    );
  }

  factory JarvisExecutionResult.error(String message) {
    return JarvisExecutionResult(
      intent: 'error',
      actions: [],
      planning: JarvisPlanning(),
      success: false,
      error: message,
    );
  }

  Map<String, dynamic> toJson() => {
        'intent': intent,
        'actions': actions.map((a) => a.toJson()).toList(),
        'planning': planning.toJson(),
        'success': success,
        if (error != null) 'error': error,
        'executedAt': executedAt.toIso8601String(),
      };
}
