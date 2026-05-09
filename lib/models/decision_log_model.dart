// lib/models/decision_log_model.dart

class DecisionModel {
  final String id;
  final String title;
  final String reasoning;
  final String category;
  final DateTime date;
  final String author;

  DecisionModel({
    required this.id,
    required this.title,
    required this.reasoning,
    required this.category,
    required this.date,
    required this.author,
  });

  factory DecisionModel.fromMap(Map<String, dynamic> map) {
    return DecisionModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      reasoning: map['reasoning'] ?? '',
      category: map['category'] ?? 'GENERAL',
      date: map['date'] != null ? DateTime.parse(map['date']) : (map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now()),
      author: map['author'] ?? 'SYSTEM',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'reasoning': reasoning,
      'category': category,
      'date': date.toIso8601String(),
      'author': author,
    };
  }
}
