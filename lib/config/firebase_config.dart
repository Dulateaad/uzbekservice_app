import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_database_service.dart';
import '../firebase_options.dart';

class FirebaseConfig {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  
  // Используем Firebase Auth сервис
  static dynamic get authService => FirebaseAuthService();
  
  // Используем Firebase Database сервис (Firestore)
  static dynamic get databaseService => FirebaseDatabaseService();
  
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase инициализирован успешно!');
      print('🔐 Готов к аутентификации пользователей');
      print('📦 Firebase Storage готов к использованию');
    } catch (e) {
      print('❌ Ошибка инициализации Firebase: $e');
      rethrow;
    }
  }
  
  // Получить текущего пользователя
  static User? get currentUser => auth.currentUser;
  
  // Проверить авторизован ли пользователь
  static bool get isAuthenticated => currentUser != null;
}
