// lib/config/api_config.dart

class ApiConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static const String cloudUrl = String.fromEnvironment('BACKEND_URL', defaultValue: "https://pathvision-backend.onrender.com/api/v1");
  static const String localUrl = "http://10.0.2.2:5000/api/v1"; // Standard Android Emulator Localhost

  static String get baseUrl => isProduction ? cloudUrl : localUrl;
}
