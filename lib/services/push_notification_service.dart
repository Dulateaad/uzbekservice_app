import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firestore_service.dart';
import '../providers/notification_navigation_provider.dart';

/// Сервис для работы с push-уведомлениями через Firebase Cloud Messaging
class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _currentToken;
  static bool _isInitialized = false;

  /// Инициализация push-уведомлений
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('📱 Push-уведомления уже инициализированы');
      return;
    }

    try {
      print('📱 Инициализация push-уведомлений...');

      // Запрос разрешений (iOS и Android)
      if (!kIsWeb) {
        NotificationSettings settings = await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );

        print('📱 Разрешения на уведомления: ${settings.authorizationStatus}');

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          print('✅ Разрешение на уведомления получено');
        } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
          print('⚠️ Временное разрешение на уведомления');
        } else {
          print('❌ Разрешение на уведомления отклонено');
          return;
        }
      }

      // Получаем токен устройства
      final token = await _getToken();
      if (token != null) {
        print('📱 FCM Token (полный): $token');
        print('💡 Скопируйте этот токен для тестирования уведомлений');
      }

      // Настраиваем обработчики уведомлений
      _setupMessageHandlers();

      _isInitialized = true;
      print('✅ Push-уведомления инициализированы');
    } catch (e) {
      print('❌ Ошибка инициализации push-уведомлений: $e');
    }
  }

  /// Получает токен устройства для отправки уведомлений
  static Future<String?> _getToken() async {
    try {
      _currentToken = await _messaging.getToken();
      print('📱 FCM Token получен: ${_currentToken?.substring(0, 20)}...');
      return _currentToken;
    } catch (e) {
      print('❌ Ошибка получения FCM токена: $e');
      return null;
    }
  }

  /// Получает текущий токен устройства
  static Future<String?> getToken() async {
    if (_currentToken == null) {
      await _getToken();
    }
    return _currentToken;
  }

  /// Сохраняет токен устройства в профиле пользователя
  static Future<void> saveTokenToUser(String userId) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Токен не получен, пропускаем сохранение');
        return;
      }

      // Получаем текущего пользователя
      final user = await FirestoreService.getUserById(userId);
      if (user == null) {
        print('⚠️ Пользователь не найден: $userId');
        return;
      }

      // Добавляем токен если его еще нет
      final tokens = List<String>.from(user.deviceTokens ?? []);
      if (!tokens.contains(token)) {
        tokens.add(token);
        print('📱 Добавляем токен в профиль пользователя');
      } else {
        print('📱 Токен уже есть в профиле пользователя');
      }

      // Обновляем пользователя
      final updatedUser = user.copyWith(
        deviceTokens: tokens,
        updatedAt: DateTime.now(),
      );

      await FirestoreService.updateUser(updatedUser);
      print('✅ Токен сохранен в профиле пользователя');
    } catch (e) {
      print('❌ Ошибка сохранения токена: $e');
    }
  }

  /// Удаляет токен из профиля пользователя
  static Future<void> removeTokenFromUser(String userId) async {
    try {
      final token = await getToken();
      if (token == null) return;

      final user = await FirestoreService.getUserById(userId);
      if (user == null) return;

      final tokens = List<String>.from(user.deviceTokens ?? []);
      tokens.remove(token);

      final updatedUser = user.copyWith(
        deviceTokens: tokens,
        updatedAt: DateTime.now(),
      );

      await FirestoreService.updateUser(updatedUser);
      print('✅ Токен удален из профиля пользователя');
    } catch (e) {
      print('❌ Ошибка удаления токена: $e');
    }
  }

  /// Настраивает обработчики сообщений
  static void _setupMessageHandlers() {
    // Обработка уведомлений когда приложение открыто (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Получено уведомление (foreground):');
      print('   Заголовок: ${message.notification?.title}');
      print('   Текст: ${message.notification?.body}');
      print('   Данные: ${message.data}');
      print('   Message ID: ${message.messageId}');

      // На web уведомления показываются автоматически через service worker
      // На мобильных платформах можно показать локальное уведомление
      if (!kIsWeb) {
        // Для мобильных платформ можно использовать flutter_local_notifications
        // чтобы показать уведомление даже когда приложение открыто
        print('💡 Для показа уведомлений в foreground на мобильных платформах');
        print('   установите flutter_local_notifications');
      }
    });

    // Обработка нажатия на уведомление когда приложение было закрыто
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 Уведомление открыло приложение:');
      print('   Заголовок: ${message.notification?.title}');
      print('   Данные: ${message.data}');

      // Здесь можно обработать навигацию на основе данных
      _handleNotificationNavigation(message.data);
    });

    // Проверка, было ли приложение открыто через уведомление
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📨 Приложение открыто через уведомление:');
        print('   Заголовок: ${message.notification?.title}');
        _handleNotificationNavigation(message.data);
      }
    });

    // Обработка обновления токена
    _messaging.onTokenRefresh.listen((String newToken) {
      print('🔄 FCM токен обновлен: ${newToken.substring(0, 20)}...');
      _currentToken = newToken;
      // Здесь можно обновить токен в профиле пользователя
    });
  }

  /// Обрабатывает навигацию на основе данных уведомления
  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    NotificationNavigationProvider.handleNavigation(data);
  }

  /// Подписывается на топик
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('✅ Подписан на топик: $topic');
    } catch (e) {
      print('❌ Ошибка подписки на топик $topic: $e');
    }
  }

  /// Отписывается от топика
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('✅ Отписан от топика: $topic');
    } catch (e) {
      print('❌ Ошибка отписки от топика $topic: $e');
    }
  }
}

/// Глобальный обработчик для background уведомлений (только для Android/iOS)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Получено фоновое уведомление:');
  print('   Заголовок: ${message.notification?.title}');
  print('   Текст: ${message.notification?.body}');
  print('   Данные: ${message.data}');
  
  // Здесь можно обработать уведомление в фоне
  // Например, обновить локальную базу данных
}

