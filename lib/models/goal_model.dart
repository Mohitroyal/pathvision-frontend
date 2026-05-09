// lib/models/goal_model.dart

class GoalModel {
  final String id;
  final String title;
  final String description;
  final double progress;
  final String category;
  final DateTime? deadline;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.category,
    this.deadline,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    double current = 0.0;
    double target = 100.0;
    
    if (map['current_value'] != null) {
      current = double.tryParse(map['current_value'].toString()) ?? 0.0;
    }
    if (map['target_value'] != null) {
      target = double.tryParse(map['target_value'].toString()) ?? 100.0;
    }

    return GoalModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      progress: target > 0 ? current / target : 0.0,
      category: map['category'] ?? 'GENERAL',
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'category': category,
      'deadline': deadline?.toIso8601String(),
    };
  }
}
