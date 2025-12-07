import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/firestore_models.dart';
import '../services/firestore_service.dart';
import '../services/test_data_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/push_notification_service.dart';
import '../services/analytics_service.dart';

class FirestoreAuthState {
  final FirestoreUser? user;
  final bool isLoading;
  final String? error;
  final String? currentPhoneNumber;
  final String? registrationName;
  final String? registrationUserType;

  const FirestoreAuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.currentPhoneNumber,
    this.registrationName,
    this.registrationUserType,
  });

  bool get isAuthenticated => user != null && user!.isVerified;
  bool get isClient => user?.userType == 'client';
  bool get isSpecialist => user?.userType == 'specialist';
  Map<String, bool> get notificationPreferences =>
      user?.notificationPreferences ?? const {'push': true, 'sms': true, 'email': true};
  List<String> get deviceTokens => user?.deviceTokens ?? const <String>[];

  FirestoreAuthState copyWith({
    FirestoreUser? user,
    bool? isLoading,
    String? error,
    String? currentPhoneNumber,
    String? registrationName,
    String? registrationUserType,
  }) {
    return FirestoreAuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPhoneNumber: currentPhoneNumber ?? this.currentPhoneNumber,
      registrationName: registrationName ?? this.registrationName,
      registrationUserType: registrationUserType ?? this.registrationUserType,
    );
  }
}

class FirestoreAuthNotifier extends StateNotifier<FirestoreAuthState> {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  static const Map<String, bool> _defaultNotificationPreferences = {
    'push': true,
    'sms': true,
    'email': true,
  };

  FirestoreAuthNotifier() : super(const FirestoreAuthState());

  FirestoreUser _withNotificationDefaults(FirestoreUser user) {
    final tokens = List<String>.from(user.deviceTokens ?? const <String>[]);
    final prefs = Map<String, bool>.from(
      user.notificationPreferences ?? _defaultNotificationPreferences,
    );
    return user.copyWith(
      deviceTokens: tokens,
      notificationPreferences: prefs,
    );
  }

  // Установка номера телефона
  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(currentPhoneNumber: phoneNumber);
  }

  // Отправка SMS кода с сохранением данных регистрации
  Future<void> sendSmsCode({
    required String phoneNumber,
    required String name,
    required String userType,
  }) async {
    state = state.copyWith(
      currentPhoneNumber: phoneNumber,
      registrationName: name,
      registrationUserType: userType,
    );
    
    final result = await _firebaseAuthService.sendSmsCode(phoneNumber);
    if (result['success'] == true) {
      print('📱 SMS код отправлен на $phoneNumber через Firebase');
    } else {
      throw Exception(result['error'] ?? 'Ошибка отправки SMS');
    }
  }

  // Вход через SMS
  Future<void> login(String phoneNumber, String smsCode, {String? verificationId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔐 Попытка входа с номером: $phoneNumber, код: $smsCode');

      // Проверяем SMS код через Firebase Phone Authentication
      final isValid = await _firebaseAuthService.verifySmsCode(phoneNumber, smsCode);
      
      if (!isValid) {
        throw Exception('Неверный код подтверждения');
      }

      // Получаем Firebase User после успешной верификации
      final firebaseUser = _firebaseAuthService.currentUser;
      print('✅ Firebase Auth: Пользователь аутентифицирован: ${firebaseUser?.uid}');

      // Ищем пользователя в Firestore
      FirestoreUser? user;
      try {
        user = await FirestoreService.getUserByPhone(phoneNumber);
      } catch (e) {
        print('⚠️ Firestore недоступен, используем локальные данные: $e');
        // Если Firestore недоступен, создаем пользователя локально
        user = _withNotificationDefaults(TestDataService.createTestUser(
          phoneNumber: phoneNumber,
          name: state.registrationName ?? 'Пользователь',
          userType: state.registrationUserType ?? 'client',
        ));
      }
      
      if (user == null) {
        // Пользователь не найден - создаем локально с сохраненными данными регистрации
        print('📝 Создаем пользователя локально для входа');
        user = _withNotificationDefaults(TestDataService.createTestUser(
          phoneNumber: phoneNumber,
          name: state.registrationName ?? 'Пользователь',
          userType: state.registrationUserType ?? 'client',
        ));
      }

      // Обновляем статус верификации и используем Firebase Auth UID как ID
      final firebaseUid = firebaseUser?.uid ?? phoneNumber;
      final verifiedUser = user.copyWith(
        id: firebaseUid, // Используем Firebase Auth UID
        isVerified: true,
        updatedAt: DateTime.now(),
      );
      final normalizedUser = _withNotificationDefaults(verifiedUser);
      
      // Пытаемся создать или обновить в Firestore
      try {
        // Проверяем, существует ли пользователь с таким ID
        final existingUser = await FirestoreService.getUserById(firebaseUid);
        if (existingUser != null) {
          await FirestoreService.updateUser(normalizedUser);
          print('✅ Пользователь обновлен в Firestore');
        } else {
          // Создаем нового пользователя
          await FirestoreService.createUser(normalizedUser);
          print('✅ Пользователь создан в Firestore');
        }
      } catch (e) {
        print('⚠️ Не удалось сохранить пользователя в Firestore: $e');
        // Продолжаем с локальными данными
      }

      state = state.copyWith(
        user: normalizedUser,
        isLoading: false,
        error: null,
      );

      // Сохраняем токен устройства для push-уведомлений
      try {
        await PushNotificationService.saveTokenToUser(normalizedUser.id);
      } catch (e) {
        print('⚠️ Не удалось сохранить токен устройства: $e');
      }

      // Логируем событие входа в Analytics
      try {
        await AnalyticsService.logLogin(
          loginMethod: 'sms',
          userId: normalizedUser.id,
        );
        await AnalyticsService.setUserProperties(
          userType: normalizedUser.userType,
          category: normalizedUser.category,
        );
      } catch (e) {
        print('⚠️ Не удалось залогировать событие входа: $e');
      }

      print('✅ Успешный вход: ${user.name} (${user.userType})');
    } catch (e) {
      print('❌ Ошибка входа: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Вход через OneID (после успешного обмена кода на токены)
  // Профиль содержит хотя бы: sub (oneIdSub), name, phone, email, picture
  Future<void> loginWithOneId({
    required String oneIdSub,
    String? phoneNumber,
    String? name,
    String? email,
    String? avatarUrl,
    String? userType, // 'client' | 'specialist' (если уже выбран ранее)
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔐 Вход через OneID: sub=$oneIdSub, phone=$phoneNumber, email=$email');

      FirestoreUser? user;

      // Сначала пробуем найти по oneIdSub, затем по телефону
      try {
        user = await FirestoreService.getUserByOneIdSub(oneIdSub);
      } catch (_) {}

      if (user == null && phoneNumber != null && phoneNumber.isNotEmpty) {
        try {
          user = await FirestoreService.getUserByPhone(phoneNumber);
        } catch (e) {
          print('⚠️ Firestore недоступен при поиске по телефону: $e');
        }
      }

      final now = DateTime.now();
      if (user == null) {
        // Создаем нового пользователя
        final created = FirestoreUser(
          id: phoneNumber?.isNotEmpty == true ? phoneNumber! : oneIdSub,
          phoneNumber: phoneNumber ?? '',
          name: (name?.isNotEmpty == true ? name! : (email ?? 'Пользователь')),
          userType: userType ?? (state.registrationUserType ?? 'client'),
          email: email,
          oneIdSub: oneIdSub,
          avatarUrl: avatarUrl,
          deviceTokens: const [],
          notificationPreferences: const {
            'push': true,
            'sms': true,
            'email': true,
          },
          createdAt: now,
          updatedAt: now,
          isVerified: true,
          rating: (userType ?? state.registrationUserType) == 'specialist' ? 0.0 : null,
          totalOrders: (userType ?? state.registrationUserType) == 'specialist' ? 0 : null,
        );
        final normalizedCreated = _withNotificationDefaults(created);

        try {
          await FirestoreService.createUser(normalizedCreated);
          user = normalizedCreated;
          print('✅ Пользователь создан (OneID) в Firestore: ${normalizedCreated.name}');
        } catch (e) {
          print('⚠️ Не удалось сохранить OneID-пользователя в Firestore: $e');
          user = normalizedCreated; // продолжаем локально
        }
      } else {
        // Обновляем существующего
        final updated = user.copyWith(
          email: email ?? user.email,
          oneIdSub: oneIdSub,
          avatarUrl: avatarUrl ?? user.avatarUrl,
          name: (name?.isNotEmpty == true ? name : null) ?? user.name,
          phoneNumber: (phoneNumber?.isNotEmpty == true ? phoneNumber : null) ?? user.phoneNumber,
          userType: (userType ?? state.registrationUserType) ?? user.userType,
          isVerified: true,
          updatedAt: now,
        );
        final normalizedUpdated = _withNotificationDefaults(updated);

        try {
          await FirestoreService.updateUser(normalizedUpdated);
          user = normalizedUpdated;
          print('✅ OneID профиль обновлен в Firestore: ${normalizedUpdated.name}');
        } catch (e) {
          print('⚠️ Не удалось обновить OneID-профиль в Firestore: $e');
          user = normalizedUpdated;
        }
      }

      state = state.copyWith(user: user, isLoading: false, error: null);
      
      // Сохраняем токен устройства для push-уведомлений
      try {
        await PushNotificationService.saveTokenToUser(user.id);
      } catch (e) {
        print('⚠️ Не удалось сохранить токен устройства: $e');
      }
      
      print('✅ Успешный вход через OneID: ${user.name} (${user.userType})');
    } catch (e) {
      print('❌ Ошибка OneID входа: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Регистрация нового пользователя
  Future<void> register({
    required String phoneNumber,
    required String name,
    required String userType,
    String? email,
    String? category,
    String? description,
    double? pricePerHour,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('📝 Регистрация пользователя: $name ($userType)');

      // Проверяем, не существует ли уже пользователь
      FirestoreUser? existingUser;
      try {
        existingUser = await FirestoreService.getUserByPhone(phoneNumber);
      } catch (e) {
        print('⚠️ Firestore недоступен при проверке существующего пользователя: $e');
        existingUser = null;
      }
      
      if (existingUser != null) {
        throw Exception('Пользователь с таким номером уже существует');
      }

      // Создаем нового пользователя (без Firebase Auth)
      final now = DateTime.now();
      final newUser = _withNotificationDefaults(FirestoreUser(
        id: phoneNumber, // Используем номер телефона как ID
        phoneNumber: phoneNumber,
        name: name,
        userType: userType,
        email: email,
        category: category,
        description: description,
        pricePerHour: pricePerHour,
        deviceTokens: const [],
        notificationPreferences: const {
          'push': true,
          'sms': true,
          'email': true,
        },
        createdAt: now,
        updatedAt: now,
        isVerified: true,
        rating: userType == 'specialist' ? 0.0 : null,
        totalOrders: userType == 'specialist' ? 0 : null,
      ));

      // Пытаемся сохранить в Firestore
      try {
        await FirestoreService.createUser(newUser);
        print('✅ Пользователь сохранен в Firestore: ${newUser.name}');
      } catch (e) {
        print('⚠️ Не удалось сохранить в Firestore: $e');
        // Продолжаем с локальными данными
      }

      state = state.copyWith(
        user: newUser,
        isLoading: false,
        error: null,
      );

      // Сохраняем токен устройства для push-уведомлений
      try {
        await PushNotificationService.saveTokenToUser(newUser.id);
      } catch (e) {
        print('⚠️ Не удалось сохранить токен устройства: $e');
      }

      print('✅ Пользователь зарегистрирован: ${newUser.name}');
    } catch (e) {
      // Если Firestore недоступен, создаем пользователя локально
      print('⚠️ Firestore недоступен, создаем пользователя локально: $e');
      
      try {
        final newUser = _withNotificationDefaults(TestDataService.createTestUser(
          phoneNumber: phoneNumber,
          name: name,
          userType: userType,
          category: category,
          description: description,
          pricePerHour: pricePerHour,
        ));

        state = state.copyWith(
          user: newUser,
          isLoading: false,
          error: null,
        );

        print('✅ Пользователь создан локально: ${newUser.name}');
      } catch (localError) {
        print('❌ Ошибка создания локального пользователя: $localError');
        state = state.copyWith(
          isLoading: false,
          error: 'Не удалось создать пользователя: $localError',
        );
      }
    }
  }

  // Обновление профиля
  Future<void> updateProfile({
    String? name,
    String? email,
    String? category,
    String? description,
    double? pricePerHour,
    String? avatarUrl,
  }) async {
    if (state.user == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedUser = state.user!.copyWith(
        name: name ?? state.user!.name,
        email: email ?? state.user!.email,
        category: category ?? state.user!.category,
        description: description ?? state.user!.description,
        pricePerHour: pricePerHour ?? state.user!.pricePerHour,
        avatarUrl: avatarUrl ?? state.user!.avatarUrl,
        updatedAt: DateTime.now(),
      );
      final normalizedUser = _withNotificationDefaults(updatedUser);

      // Пытаемся обновить в Firestore
      try {
        await FirestoreService.updateUser(normalizedUser);
        print('✅ Профиль обновлен в Firestore: ${normalizedUser.name}');
      } catch (e) {
        print('⚠️ Не удалось обновить профиль в Firestore: $e');
        // Продолжаем с локальными данными
      }

      state = state.copyWith(
        user: normalizedUser,
        isLoading: false,
        error: null,
      );

      print('✅ Профиль обновлен: ${normalizedUser.name}');
    } catch (e) {
      print('❌ Ошибка обновления профиля: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> registerDeviceToken(String token) async {
    if (token.isEmpty || state.user == null) return;
    final user = state.user!;
    final tokens = List<String>.from(user.deviceTokens ?? const <String>[]);
    if (tokens.contains(token)) return;

    try {
      await FirestoreService.addDeviceToken(user.id, token);
      tokens.add(token);
      state = state.copyWith(user: user.copyWith(deviceTokens: tokens));
    } catch (e) {
      print('❌ Не удалось зарегистрировать токен устройства: $e');
    }
  }

  Future<void> unregisterDeviceToken(String token) async {
    if (token.isEmpty || state.user == null) return;
    final user = state.user!;
    final tokens = List<String>.from(user.deviceTokens ?? const <String>[]);
    if (!tokens.contains(token)) return;

    try {
      await FirestoreService.removeDeviceToken(user.id, token);
      tokens.remove(token);
      state = state.copyWith(user: user.copyWith(deviceTokens: tokens));
    } catch (e) {
      print('❌ Не удалось удалить токен устройства: $e');
    }
  }

  Future<void> updateNotificationPreferences({
    bool? push,
    bool? sms,
    bool? email,
  }) async {
    if (state.user == null) return;

    final user = state.user!;
    final prefs = Map<String, bool>.from(
      user.notificationPreferences ?? _defaultNotificationPreferences,
    );

    if (push != null) prefs['push'] = push;
    if (sms != null) prefs['sms'] = sms;
    if (email != null) prefs['email'] = email;

    try {
      await FirestoreService.updateNotificationPreferences(user.id, prefs);
    } catch (e) {
      print('❌ Не удалось обновить настройки уведомлений: $e');
    }

    state = state.copyWith(
      user: user.copyWith(notificationPreferences: prefs),
    );
  }

  // Выход
  void logout() {
    state = const FirestoreAuthState();
    print('👋 Пользователь вышел из системы');
  }

}

// Провайдер для состояния аутентификации
final firestoreAuthProvider = StateNotifierProvider<FirestoreAuthNotifier, FirestoreAuthState>((ref) {
  return FirestoreAuthNotifier();
});
