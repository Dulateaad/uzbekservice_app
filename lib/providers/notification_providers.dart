import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../providers/firestore_auth_provider.dart';

// Сервис уведомлений
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Инициализация сервиса уведомлений
final notificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.read(notificationServiceProvider);
  await service.initialize();
});

// Получение текущего пользователя
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(firestoreAuthProvider);
  return authState.user?.id;
});

// Получение уведомлений для текущего пользователя
final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  
  final service = ref.watch(notificationServiceProvider);
  return service.getNotificationsForUser(userId);
});

// Получение количества непрочитанных уведомлений
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(0);
  
  final service = ref.watch(notificationServiceProvider);
  return service.getUnreadCount(userId);
});

// Провайдер для отметки уведомления как прочитанного
final markNotificationAsReadProvider = Provider.family<Future<void> Function(String), String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return (notificationId) => service.markAsRead(notificationId);
});

// Провайдер для отметки всех уведомлений как прочитанных
final markAllNotificationsAsReadProvider = Provider.family<Future<void> Function(), String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return () => service.markAllAsRead(userId);
});

// Провайдер для удаления уведомления
final deleteNotificationProvider = Provider.family<Future<void> Function(String), String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return (notificationId) => service.deleteNotification(notificationId);
});

// Провайдеры для создания различных типов уведомлений
final createOrderNotificationProvider = Provider.family<Future<void> Function({
  required String specialistId,
  required String clientName,
  required String serviceName,
  required String orderId,
}), String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return ({
    required specialistId,
    required clientName,
    required serviceName,
    required orderId,
  }) => service.notifyOrderCreated(
    specialistId: specialistId,
    clientName: clientName,
    serviceName: serviceName,
    orderId: orderId,
  );
});

final createMessageNotificationProvider = Provider.family<Future<void> Function({
  required String receiverId,
  required String senderName,
  required String message,
  required String chatId,
}), String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return ({
    required receiverId,
    required senderName,
    required message,
    required chatId,
  }) => service.notifyMessageReceived(
    receiverId: receiverId,
    senderName: senderName,
    message: message,
    chatId: chatId,
  );
});

final createPaymentNotificationProvider = Provider.family<Future<void> Function({
  required String specialistId,
  required double amount,
  required String orderId,
}), String>((ref, userId) {
  final service = ref.watch(notificationServiceProvider);
  return ({
    required specialistId,
    required amount,
    required orderId,
  }) => service.notifyPaymentReceived(
    specialistId: specialistId,
    amount: amount,
    orderId: orderId,
  );
});

// Провайдер для фильтрации уведомлений по типу
final filteredNotificationsProvider = Provider.family<List<NotificationModel>, NotificationType?>((ref, filterType) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (notifications) {
      if (filterType == null) return notifications;
      return notifications.where((notification) => notification.type == filterType).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Провайдер для получения уведомлений по приоритету
final highPriorityNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (notifications) {
      return notifications.where((notification) => 
        notification.priority == NotificationPriority.high || 
        notification.priority == NotificationPriority.urgent
      ).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Провайдер для статистики уведомлений
final notificationStatsProvider = Provider<Map<String, int>>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (notifications) {
      final stats = <String, int>{
        'total': notifications.length,
        'unread': notifications.where((n) => !n.isRead).length,
        'today': notifications.where((n) => 
          n.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 1)))
        ).length,
        'thisWeek': notifications.where((n) => 
          n.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
        ).length,
      };
      
      // Статистика по типам
      for (final type in NotificationType.values) {
        stats[type.name] = notifications.where((n) => n.type == type).length;
      }
      
      return stats;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
