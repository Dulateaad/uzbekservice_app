import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_firestore_service.dart';
import '../services/simple_sms_service.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final String? currentPhoneNumber; // Добавляем текущий номер телефона

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.currentPhoneNumber,
  });

  bool get isAuthenticated => user != null && user!.isVerified;
  bool get isClient => user?.userType == 'client';
  bool get isSpecialist => user?.userType == 'specialist';

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    String? currentPhoneNumber,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPhoneNumber: currentPhoneNumber ?? this.currentPhoneNumber,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestoreService _firestoreService = FirebaseFirestoreService();
  final SimpleSmsService _smsService = SimpleSmsService();

  AuthNotifier() : super(const AuthState());

  /// Устанавливает текущий номер телефона
  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(currentPhoneNumber: phoneNumber);
    print('📱 Номер телефона установлен: $phoneNumber');
  }

  Future<void> login(String phoneNumber, String smsCode) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔍 AuthProvider: Проверяем код для номера: "$phoneNumber"');
      print('🔍 AuthProvider: Введенный код: "$smsCode"');
      
      // Проверяем SMS код через простой сервис
      final isValid = await _smsService.verifySmsCode(phoneNumber, smsCode);
      
      print('🔍 AuthProvider: Результат проверки: $isValid');

      if (!isValid) {
        throw 'Неверный код подтверждения';
      }

      // Создаем пользователя локально для быстрого тестирования
      final user = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        name: 'Пользователь',
        userType: 'client',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
      );
      
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );

      print('Пользователь успешно аутентифицирован: ${user.phoneNumber}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('Ошибка аутентификации: $e');
    }
  }

  Future<void> register({
    required String phoneNumber,
    required String name,
    required String userType,
    String? email,
    String? category,
    String? description,
    double? pricePerHour,
    String? avatar,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Создаем пользователя в Firestore
      final user = await _firestoreService.createUser(
        phoneNumber: phoneNumber,
        name: name,
        userType: userType,
        email: email,
        category: category,
        description: description,
        pricePerHour: pricePerHour,
        avatar: avatar,
      );
      
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );
      
      print('Пользователь зарегистрирован: ${user.name} (${user.userType})');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('Ошибка регистрации: $e');
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Здесь будет логика выхода
      await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
      
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});