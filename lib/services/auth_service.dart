import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();
  
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Инициализация
  Future<void> initialize() async {
    _apiService.initialize();
    
    // Проверяем сохраненный токен
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }

  // Отправка SMS кода
  Future<String> sendSmsCode(String phoneNumber) async {
    try {
      // В реальном приложении здесь будет интеграция с SMS сервисом
      // Пока возвращаем тестовый код
      await Future.delayed(const Duration(seconds: 1));
      return '123456'; // Тестовый код
    } catch (e) {
      throw 'Ошибка отправки SMS: $e';
    }
  }

  // Проверка SMS кода
  Future<UserModel> verifySmsCode(String phoneNumber, String code) async {
    try {
      // В реальном приложении здесь будет проверка кода через API
      if (code != '123456') {
        throw 'Неверный код подтверждения';
      }

      // Создаем пользователя в Firebase
      final credential = await _auth.signInAnonymously();
      final firebaseUser = credential.user;
      
      if (firebaseUser == null) {
        throw 'Ошибка создания пользователя';
      }

      // Создаем модель пользователя
      final user = UserModel(
        id: firebaseUser.uid,
        phoneNumber: phoneNumber,
        name: '',
        userType: 'client',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Сохраняем токен
      final token = await firebaseUser.getIdToken();
      if (token != null) {
        await _saveAuthToken(token);
        _apiService.setAuthToken(token);
      }

      return user;
    } catch (e) {
      throw 'Ошибка проверки кода: $e';
    }
  }

  // Регистрация пользователя
  Future<UserModel> registerUser({
    required String phoneNumber,
    required String name,
    required String userType,
    String? email,
    String? category,
    String? description,
    double? pricePerHour,
  }) async {
    try {
      // В реальном приложении здесь будет регистрация через API
      await Future.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: currentUser?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        name: name,
        email: email,
        userType: userType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return user;
    } catch (e) {
      throw 'Ошибка регистрации: $e';
    }
  }

  // Вход в систему
  Future<UserModel> login(String phoneNumber, String password) async {
    try {
      // В реальном приложении здесь будет вход через API
      await Future.delayed(const Duration(seconds: 1));

      final user = UserModel(
        id: 'user_1',
        phoneNumber: phoneNumber,
        name: 'Пользователь',
        userType: 'client',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return user;
    } catch (e) {
      throw 'Ошибка входа: $e';
    }
  }

  // Выход из системы
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _clearAuthToken();
      _apiService.clearAuthToken();
    } catch (e) {
      throw 'Ошибка выхода: $e';
    }
  }

  // Получение текущего пользователя
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = currentUser;
      if (firebaseUser == null) return null;

      // В реальном приложении здесь будет получение данных пользователя из API
      return UserModel(
        id: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber ?? '',
        name: firebaseUser.displayName ?? '',
        userType: 'client',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  // Обновление профиля
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      // В реальном приложении здесь будет обновление через API
      await Future.delayed(const Duration(seconds: 1));

      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw 'Пользователь не найден';
      }

      return currentUser.copyWith(
        name: data['name'],
        email: data['email'],
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw 'Ошибка обновления профиля: $e';
    }
  }

  // Проверка авторизации
  Future<bool> isAuthenticated() async {
    try {
      final firebaseUser = currentUser;
      if (firebaseUser == null) return false;

      // Проверяем токен
      final token = await firebaseUser.getIdToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Сохранение токена
  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Очистка токена
  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Получение токена
  Future<String?> getAuthToken() async {
    try {
      final firebaseUser = currentUser;
      if (firebaseUser == null) return null;
      
      return await firebaseUser.getIdToken();
    } catch (e) {
      return null;
    }
  }
}