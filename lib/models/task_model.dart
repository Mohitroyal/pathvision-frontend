// lib/models/task_model.dart

enum TaskStatus { backlog, todo, inProgress, done }
enum TaskPriority { critical, high, medium, low }
enum TaskSize { s, m, l, xl }

class ChecklistItem {
  String title;
  bool isDone;
  ChecklistItem({required this.title, this.isDone = false});

  Map<String, dynamic> toMap() => {'title': title, 'is_done': isDone};
  factory ChecklistItem.fromMap(Map<String, dynamic> map) => ChecklistItem(title: map['title'], isDone: map['is_done'] ?? false);
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String? project;
  final String? department;
  final List<String> tags;
  final TaskPriority priority;
  final TaskSize size;
  final DateTime? dueDate;
  final List<ChecklistItem> checklist;
  final List<String> assignedMembers;
  final String? reminder;
  final String? privateNotes;
  final String? milestone;
  TaskStatus status;
  bool isPinned;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.project,
    this.department,
    List<String>? tags,
    this.priority = TaskPriority.medium,
    this.size = TaskSize.m,
    this.dueDate,
    List<ChecklistItem>? checklist,
    List<String>? assignedMembers,
    this.reminder,
    this.privateNotes,
    this.milestone,
    this.status = TaskStatus.backlog,
    this.isPinned = false,
  }) : this.tags = tags ?? [],
       this.checklist = checklist ?? [],
       this.assignedMembers = assignedMembers ?? [];

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    final meta = map['metadata'] ?? {};
    return TaskModel(
      id: map['id'].toString(),
      title: map['title'],
      description: map['description'],
      project: map['project_name'] ?? map['project'] ?? meta['project'],
      department: meta['department'],
      status: _statusFromString(map['status']),
      priority: _priorityFromString(map['priority']),
      size: _sizeFromString(meta['size']),
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      tags: List<String>.from(meta['tags'] ?? []),
      checklist: (meta['checklist'] as List?)?.map((e) => ChecklistItem.fromMap(e)).toList(),
      assignedMembers: map['assigned_user'] != null ? [map['assigned_user']] : List<String>.from(meta['assignedMembers'] ?? []),
      reminder: meta['reminder'],
      privateNotes: meta['privateNotes'],
      milestone: meta['milestone'],
      isPinned: map['is_pinned'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'due_date': dueDate?.toIso8601String(),
      'is_pinned': isPinned,
      'metadata': {
        'project': project,
        'department': department,
        'tags': tags,
        'size': size.name,
        'checklist': checklist.map((e) => e.toMap()).toList(),
        'assignedMembers': assignedMembers,
        'reminder': reminder,
        'privateNotes': privateNotes,
        'milestone': milestone,
      }
    };
  }

  static TaskStatus _statusFromString(String? status) {
    switch (status) {
      case 'todo': return TaskStatus.todo;
      case 'in_progress':
      case 'inProgress': return TaskStatus.inProgress;
      case 'done': return TaskStatus.done;
      default: return TaskStatus.backlog;
    }
  }

  static TaskPriority _priorityFromString(String? priority) {
    switch (priority) {
      case 'critical': return TaskPriority.critical;
      case 'high': return TaskPriority.high;
      case 'low': return TaskPriority.low;
      default: return TaskPriority.medium;
    }
  }

  static TaskSize _sizeFromString(String? size) {
    switch (size) {
      case 's': return TaskSize.s;
      case 'l': return TaskSize.l;
      case 'xl': return TaskSize.xl;
      default: return TaskSize.m;
    }
  }
}
