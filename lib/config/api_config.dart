class ApiConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static const String cloudUrl = String.fromEnvironment('BACKEND_URL', defaultValue: "https://pathvision-backend.onrender.com/api/v1");
  static const String localUrl = "http://10.0.2.2:5000/api/v1"; 

  static String get baseUrl => isProduction ? cloudUrl : localUrl;

  // Supabase Config
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://bykivmvznqbgnjlokxd.supabase.co');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ5a2l2bXZ6bnFiZ25uamxva3hkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzMDY1MTksImV4cCI6MjA5Mzg4MjUxOX0.LUarkyRAHVQHCa68d9iFC4CorXxsdzCIn_xfF_tla2c');
}
