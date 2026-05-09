// lib/models/risk_model.dart

enum RiskSeverity { critical, overdue, monitor, plan }

extension RiskSeverityX on RiskSeverity {
  String get label {
    switch (this) {
      case RiskSeverity.critical:
        return 'CRITICAL';
      case RiskSeverity.overdue:
        return 'OVERDUE';
      case RiskSeverity.monitor:
        return 'MONITOR';
      case RiskSeverity.plan:
        return 'PLAN NEEDED';
    }
  }
}

class RiskModel {
  final String id;
  String title;
  String description;
  RiskSeverity severity;
  List<String> tags;
  final DateTime createdAt;
  String? owner;

  RiskModel({
    required this.id,
    required this.title,
    required this.description,
    this.severity = RiskSeverity.monitor,
    this.tags = const [],
    DateTime? createdAt,
    this.owner,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RiskModel.fromMap(Map<String, dynamic> map) {
    return RiskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      severity: _severityFromString(map['impact_level']),
      tags: [], // Metadata could contain tags
      createdAt: DateTime.parse(map['created_at']),
      owner: map['project_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'impact_level': severity.name,
    };
  }

  static RiskSeverity _severityFromString(String? level) {
    switch (level) {
      case 'high':
      case 'critical': return RiskSeverity.critical;
      case 'overdue': return RiskSeverity.overdue;
      case 'low': return RiskSeverity.plan;
      default: return RiskSeverity.monitor;
    }
  }
}
