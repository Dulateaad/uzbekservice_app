import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  orderCreated,
  orderAccepted,
  orderCompleted,
  orderCancelled,
  messageReceived,
  paymentReceived,
  reminder,
  promotion,
  system,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.priority = NotificationPriority.medium,
    required this.createdAt,
    this.isRead = false,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.readAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'data': data,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool? ?? false,
      data: map['data'] as Map<String, dynamic>?,
      imageUrl: map['imageUrl'] as String?,
      actionUrl: map['actionUrl'] as String?,
      readAt: map['readAt'] != null ? (map['readAt'] as Timestamp).toDate() : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      readAt: readAt ?? this.readAt,
    );
  }

  // Вспомогательные методы для получения иконки и цвета
  String get iconName {
    switch (type) {
      case NotificationType.orderCreated:
        return 'shopping_bag';
      case NotificationType.orderAccepted:
        return 'check_circle';
      case NotificationType.orderCompleted:
        return 'done_all';
      case NotificationType.orderCancelled:
        return 'cancel';
      case NotificationType.messageReceived:
        return 'message';
      case NotificationType.paymentReceived:
        return 'payment';
      case NotificationType.reminder:
        return 'schedule';
      case NotificationType.promotion:
        return 'local_offer';
      case NotificationType.system:
        return 'info';
    }
  }

  String get priorityText {
    switch (priority) {
      case NotificationPriority.low:
        return 'Низкий';
      case NotificationPriority.medium:
        return 'Средний';
      case NotificationPriority.high:
        return 'Высокий';
      case NotificationPriority.urgent:
        return 'Срочный';
    }
  }
}
