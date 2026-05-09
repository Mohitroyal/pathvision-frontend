// lib/models/ai_message.dart

enum MessageSender { user, ai }

class AiMessage {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;

  AiMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
  });
}
