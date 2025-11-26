// Заглушка для совместимости - использует Supabase вместо Firebase
// TODO: Постепенно заменить все использования на Supabase сервисы напрямую

import '../config/supabase_config.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_database_service.dart';

/// Заглушка для совместимости с существующим кодом
/// Использует Supabase вместо Firebase
class FirebaseConfig {
  // Используем Supabase Auth вместо Firebase Auth
  static dynamic get auth => SupabaseAuthService();
  
  // Используем Supabase Database вместо Firestore
  static dynamic get firestore => SupabaseDatabaseService();
  
  static Future<void> initialize() async {
    // Инициализация уже выполнена в main.dart через SupabaseConfig
    // Здесь ничего не делаем, так как Supabase уже инициализирован
    print('✅ FirebaseConfig: Используется Supabase вместо Firebase');
  }
}
