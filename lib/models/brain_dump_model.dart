// lib/models/brain_dump_model.dart

enum BrainDumpTag { idea, task, reminder }

extension BrainDumpTagX on BrainDumpTag {
  String get label {
    switch (this) {
      case BrainDumpTag.idea:
        return 'idea';
      case BrainDumpTag.task:
        return 'task';
      case BrainDumpTag.reminder:
        return 'reminder';
    }
  }
}

class BrainDumpEntry {
  final String id;
  String content;
  final DateTime createdAt;
  BrainDumpTag tag;
  bool processed;

  BrainDumpEntry({
    required this.id,
    required this.content,
    required this.createdAt,
    this.tag = BrainDumpTag.idea,
    this.processed = false,
  });

  factory BrainDumpEntry.fromMap(Map<String, dynamic> map) {
    return BrainDumpEntry(
      id: map['id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      tag: _tagFromString(map['metadata']?['tag']),
      processed: map['metadata']?['processed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'metadata': {
        'tag': tag.name,
        'processed': processed,
      }
    };
  }

  static BrainDumpTag _tagFromString(String? tag) {
    switch (tag) {
      case 'task': return BrainDumpTag.task;
      case 'reminder': return BrainDumpTag.reminder;
      default: return BrainDumpTag.idea;
    }
  }
}
