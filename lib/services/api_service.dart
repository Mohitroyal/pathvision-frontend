import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static const bool useMockData = false; 
  static String baseUrl = ApiConfig.baseUrl;
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> get _headers {
    final headers = {"Content-Type": "application/json"};
    if (_token != null) {
      headers["Authorization"] = "Bearer $_token";
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockData(endpoint);
    }
    final response = await http.get(Uri.parse("$baseUrl$endpoint"), headers: _headers);
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception("Failed to load data from $endpoint");
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (endpoint == "/auth/login" || endpoint == "/auth/register") {
        return {
          "token": "mock_token_12345",
          "user": {
            "id": "mock_user_id",
            "email": data["email"] ?? "demo@pathvision.os",
            "full_name": data["full_name"] ?? "MOHITH ROYAL",
            "role": data["role"] ?? "EXECUTIVE"
          }
        };
      }
      return data;
    }
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) return json.decode(response.body);
    throw Exception("Failed to post data to $endpoint");
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    if (useMockData) return data;
    final response = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception("Failed to update data at $endpoint");
  }

  static Future<void> delete(String endpoint) async {
    if (useMockData) return;
    final response = await http.delete(Uri.parse("$baseUrl$endpoint"), headers: _headers);
    if (response.statusCode != 200) throw Exception("Failed to delete data at $endpoint");
  }

  static dynamic _getMockData(String endpoint) {
    if (endpoint.contains("/tasks")) return [];
    if (endpoint.contains("/projects")) return [];
    if (endpoint.contains("/users")) return [];
    if (endpoint.contains("/planner")) return [];
    if (endpoint.contains("/milestones")) return [];
    if (endpoint.contains("/risks")) return [];
    if (endpoint.contains("/translations")) return [];
    if (endpoint.contains("/dashboard")) {
        return {
            "stats": {"tasks": 12, "projects": 4, "revenue": 125000},
            "recent_activity": []
        };
    }
    return {};
  }
}
