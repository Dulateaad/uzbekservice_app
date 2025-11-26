import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Project ID: rxouorcmwrgrhkrunbfi
  // TODO: Замените anon key на ваш реальный ключ из Settings > API
  static const String supabaseUrl = 'https://rxouorcmwrgrhkrunbfi.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ4b3VvcmNtd3JncmhrcnVuYmZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwODEzMTEsImV4cCI6MjA3OTY1NzMxMX0.oCQOa3rPUuTEPip1xmxOeUvJozaTRECrgVe7NU0J_m0';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    
    print('✅ Supabase инициализирован успешно!');
    print('🔐 Готов к аутентификации пользователей');
  }
  
  // Получить текущего пользователя
  static User? get currentUser => client.auth.currentUser;
  
  // Проверить авторизован ли пользователь
  static bool get isAuthenticated => currentUser != null;
}
