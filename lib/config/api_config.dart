// lib/config/api_config.dart

class ApiConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  // Replace this with your actual Render/Cloud URL later
  static const String cloudUrl = "https://pathvision-os-api.onrender.com/api/v1";
  static const String localUrl = "http://localhost:5000/api/v1";

  static String get baseUrl => isProduction ? cloudUrl : localUrl;
}
