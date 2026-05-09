// lib/services/ai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: 'YOUR_GROQ_API_KEY');

  Future<String> getJarvisResponse(String prompt, String context) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.1-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "You are JARVIS, the PathVision AI Operating System. "
                        "You manage tasks, projects, risks, and finance. "
                        "Keep responses concise, technical, and premium. "
                        "Current System Context: $context"
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "ERROR: Neural Link Interrupted (${response.statusCode})";
      }
    } catch (e) {
      return "ERROR: Connection Timeout ($e)";
    }
  }

  // Parses natural language into system commands
  Future<Map<String, dynamic>> parseCommand(String command) async {
    final prompt = "Parse this command into a JSON structure for PathVision OS. "
                  "Identify 'action' (create_task, set_reminder, etc), 'title', 'due_date', 'priority'. "
                  "Command: $command";
    
    final response = await getJarvisResponse(prompt, "Command Parser Mode");
    try {
      // Find JSON block in response
      final start = response.indexOf('{');
      final end = response.lastIndexOf('}') + 1;
      return jsonDecode(response.substring(start, end));
    } catch (e) {
      return {"action": "unknown", "raw": command};
    }
  }
}
