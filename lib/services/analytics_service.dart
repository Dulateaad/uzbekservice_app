import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// Сервис для работы с Firebase Analytics
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  
  static FirebaseAnalytics get analytics => _analytics;
  static FirebaseAnalyticsObserver get observer => _observer;

  /// Логирует событие входа пользователя
  static Future<void> logLogin({
    required String loginMethod, // 'sms', 'oneid', 'phone'
    String? userId,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logLogin - method: $loginMethod');
    }
    await _analytics.logLogin(loginMethod: loginMethod);
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }
  }

  /// Логирует событие регистрации
  static Future<void> logSignUp({
    required String signUpMethod,
    String? userId,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logSignUp - method: $signUpMethod');
    }
    await _analytics.logSignUp(signUpMethod: signUpMethod);
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }
  }

  /// Логирует создание заказа
  static Future<void> logOrderCreated({
    required String orderId,
    required String specialistId,
    required double amount,
    String? category,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logOrderCreated - orderId: $orderId, amount: $amount');
    }
    await _analytics.logEvent(
      name: 'order_created',
      parameters: {
        'order_id': orderId,
        'specialist_id': specialistId,
        'value': amount,
        'currency': 'UZS',
        if (category != null) 'category': category,
      },
    );
    
    // Также используем стандартное событие ecommerce_purchase
    await _analytics.logPurchase(
      currency: 'UZS',
      value: amount,
      parameters: {
        'order_id': orderId,
        'specialist_id': specialistId,
        if (category != null) 'category': category,
      },
    );
  }

  /// Логирует изменение статуса заказа
  static Future<void> logOrderStatusChanged({
    required String orderId,
    required String oldStatus,
    required String newStatus,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logOrderStatusChanged - orderId: $orderId, $oldStatus → $newStatus');
    }
    await _analytics.logEvent(
      name: 'order_status_changed',
      parameters: {
        'order_id': orderId,
        'old_status': oldStatus,
        'new_status': newStatus,
      },
    );
  }

  /// Логирует начало процесса оплаты
  static Future<void> logPaymentStarted({
    required String orderId,
    required String paymentMethod, // 'click', 'payme', 'cash'
    required double amount,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logPaymentStarted - orderId: $orderId, method: $paymentMethod');
    }
    await _analytics.logBeginCheckout(
      value: amount,
      currency: 'UZS',
      parameters: {
        'order_id': orderId,
        'payment_method': paymentMethod,
      },
    );
  }

  /// Логирует успешную оплату
  static Future<void> logPaymentCompleted({
    required String orderId,
    required String paymentMethod,
    required double amount,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logPaymentCompleted - orderId: $orderId, method: $paymentMethod');
    }
    await _analytics.logEvent(
      name: 'payment_completed',
      parameters: {
        'order_id': orderId,
        'payment_method': paymentMethod,
        'value': amount,
        'currency': 'UZS',
      },
    );
  }

  /// Логирует просмотр специалиста
  static Future<void> logSpecialistViewed({
    required String specialistId,
    String? category,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logSpecialistViewed - specialistId: $specialistId');
    }
    await _analytics.logEvent(
      name: 'view_item',
      parameters: {
        'item_id': specialistId,
        'item_name': 'Specialist',
        if (category != null) 'item_category': category,
      },
    );
  }

  /// Логирует поиск специалистов
  static Future<void> logSearch({
    required String searchTerm,
    String? category,
    int? resultCount,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logSearch - term: $searchTerm');
    }
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        if (category != null) 'category': category,
        if (resultCount != null) 'result_count': resultCount,
      },
    );
  }

  /// Логирует отправку сообщения в чате
  static Future<void> logMessageSent({
    required String chatId,
    required String recipientId,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logMessageSent - chatId: $chatId');
    }
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'chat_id': chatId,
        'recipient_id': recipientId,
      },
    );
  }

  /// Логирует создание отзыва
  static Future<void> logReviewCreated({
    required String reviewId,
    required String specialistId,
    required double rating,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logReviewCreated - reviewId: $reviewId, rating: $rating');
    }
    await _analytics.logEvent(
      name: 'review_created',
      parameters: {
        'review_id': reviewId,
        'specialist_id': specialistId,
        'rating': rating,
      },
    );
  }

  /// Устанавливает свойства пользователя
  static Future<void> setUserProperties({
    String? userType, // 'client', 'specialist'
    String? category,
  }) async {
    if (userType != null) {
      await _analytics.setUserProperty(name: 'user_type', value: userType);
    }
    if (category != null) {
      await _analytics.setUserProperty(name: 'category', value: category);
    }
  }

  /// Устанавливает текущий экран
  static Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: setCurrentScreen - $screenName');
    }
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Логирует кастомное событие
  static Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    if (kDebugMode) {
      print('📊 Analytics: logCustomEvent - $eventName');
    }
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters != null 
          ? parameters.map((key, value) => MapEntry(key, value as Object))
          : null,
    );
  }
}

