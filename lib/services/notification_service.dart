import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Инициализация сервиса уведомлений
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Настройка локальных уведомлений
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Запрос разрешений
    await _requestPermissions();

    _isInitialized = true;
  }

  // Запрос разрешений на уведомления
  Future<void> _requestPermissions() async {
    // Для Android
    await Permission.notification.request();
    
    // Для iOS
    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse response) {
    // Здесь можно добавить логику навигации
    print('Уведомление нажато: ${response.payload}');
  }

  // Создание уведомления
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      final notificationRef = _firestore.collection('notifications').doc();
      final notification = NotificationModel(
        id: notificationRef.id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        priority: priority,
        createdAt: DateTime.now(),
        data: data,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
      );

      await notificationRef.set(notification.toMap());

      // Отправка локального уведомления
      await _showLocalNotification(notification);
    } catch (e) {
      print('Ошибка создания уведомления: $e');
    }
  }

  // Показать локальное уведомление
  Future<void> _showLocalNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'uzbekservice_channel',
      'UzbekService Notifications',
      channelDescription: 'Уведомления от UzbekService',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.actionUrl,
    );
  }

  // Получение уведомлений для пользователя
  Stream<List<NotificationModel>> getNotificationsForUser(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data()))
            .toList());
  }

  // Получение количества непрочитанных уведомлений
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Отметить уведомление как прочитанное
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Ошибка отметки уведомления как прочитанного: $e');
    }
  }

  // Отметить все уведомления как прочитанные
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final unreadNotifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in unreadNotifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      print('Ошибка отметки всех уведомлений как прочитанных: $e');
    }
  }

  // Удалить уведомление
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Ошибка удаления уведомления: $e');
    }
  }

  // Создание уведомления о новом заказе
  Future<void> notifyOrderCreated({
    required String specialistId,
    required String clientName,
    required String serviceName,
    required String orderId,
  }) async {
    await createNotification(
      userId: specialistId,
      title: 'Новый заказ!',
      body: '$clientName заказал услугу "$serviceName"',
      type: NotificationType.orderCreated,
      priority: NotificationPriority.high,
      data: {
        'orderId': orderId,
        'clientName': clientName,
        'serviceName': serviceName,
      },
      actionUrl: '/orders/$orderId',
    );
  }

  // Создание уведомления о принятии заказа
  Future<void> notifyOrderAccepted({
    required String clientId,
    required String specialistName,
    required String serviceName,
    required String orderId,
  }) async {
    await createNotification(
      userId: clientId,
      title: 'Заказ принят!',
      body: '$specialistName принял ваш заказ "$serviceName"',
      type: NotificationType.orderAccepted,
      priority: NotificationPriority.high,
      data: {
        'orderId': orderId,
        'specialistName': specialistName,
        'serviceName': serviceName,
      },
      actionUrl: '/orders/$orderId',
    );
  }

  // Создание уведомления о завершении заказа
  Future<void> notifyOrderCompleted({
    required String clientId,
    required String specialistName,
    required String serviceName,
    required String orderId,
  }) async {
    await createNotification(
      userId: clientId,
      title: 'Заказ завершен!',
      body: '$specialistName завершил ваш заказ "$serviceName"',
      type: NotificationType.orderCompleted,
      priority: NotificationPriority.medium,
      data: {
        'orderId': orderId,
        'specialistName': specialistName,
        'serviceName': serviceName,
      },
      actionUrl: '/orders/$orderId',
    );
  }

  // Создание уведомления о новом сообщении
  Future<void> notifyMessageReceived({
    required String receiverId,
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    await createNotification(
      userId: receiverId,
      title: 'Новое сообщение от $senderName',
      body: message,
      type: NotificationType.messageReceived,
      priority: NotificationPriority.medium,
      data: {
        'chatId': chatId,
        'senderName': senderName,
      },
      actionUrl: '/chat/$chatId',
    );
  }

  // Создание уведомления о платеже
  Future<void> notifyPaymentReceived({
    required String specialistId,
    required double amount,
    required String orderId,
  }) async {
    await createNotification(
      userId: specialistId,
      title: 'Платеж получен!',
      body: 'Вы получили ${amount.toStringAsFixed(0)} сум за выполненную работу',
      type: NotificationType.paymentReceived,
      priority: NotificationPriority.high,
      data: {
        'orderId': orderId,
        'amount': amount,
      },
      actionUrl: '/orders/$orderId',
    );
  }

  // Создание напоминания
  Future<void> notifyReminder({
    required String userId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.reminder,
      priority: NotificationPriority.medium,
      data: {
        'scheduledTime': scheduledTime.toIso8601String(),
      },
    );
  }

  // Создание промо-уведомления
  Future<void> notifyPromotion({
    required String userId,
    required String title,
    required String body,
    required String promoCode,
  }) async {
    await createNotification(
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.promotion,
      priority: NotificationPriority.low,
      data: {
        'promoCode': promoCode,
      },
      actionUrl: '/promo/$promoCode',
    );
  }
}
