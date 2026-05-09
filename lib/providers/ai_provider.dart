// lib/providers/ai_provider.dart

import 'package:flutter/foundation.dart';
import '../models/ai_message.dart';
import '../services/api_service.dart';

class AiProvider with ChangeNotifier {
  final List<AiMessage> _messages = [
    AiMessage(
      id: 'm1',
      content: 'Good morning. I am JARVIS. How can I optimize your workflow today?',
      sender: MessageSender.ai,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  List<AiMessage> get messages => _messages;
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    _messages.add(AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    _isProcessing = true;
    notifyListeners();

    try {
      final response = await ApiService.post("/ai/command", {'text': content});
      
      _messages.add(AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response['message'] ?? 'Action completed.',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Error processing command: $e',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
