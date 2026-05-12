// lib/providers/ai_provider.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // Last executed action — listeners can refresh their data on change
  String? _lastAction;
  String? get lastAction => _lastAction;

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Current authenticated user ID
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // Add user message immediately
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
      final response = await ApiService.post("/ai/command", {
        'text': content,
        if (userId != null) 'userId': userId,
      });

      final action = response['action'] as String?;
      final message = response['message'] ?? 'Action completed.';

      _messages.add(AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));

      // Track the action so dependent screens can reload data
      if (action != null && action != 'conversation' && action != 'external_query') {
        _lastAction = action;
        debugPrint('[AiProvider] Action executed: $action');
      }
    } catch (e) {
      _messages.add(AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Neural link error: $e',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
