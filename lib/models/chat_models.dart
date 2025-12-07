import 'package:cloud_firestore/cloud_firestore.dart';

// Модель чата
class ChatModel {
  final String id;
  final String clientId;
  final String specialistId;
  final String? orderId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? clientData;
  final Map<String, dynamic>? specialistData;

  ChatModel({
    required this.id,
    required this.clientId,
    required this.specialistId,
    this.orderId,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.clientData,
    this.specialistData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'specialistId': specialistId,
      'orderId': orderId,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'clientData': clientData,
      'specialistData': specialistData,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      specialistId: map['specialistId'] ?? '',
      orderId: map['orderId'],
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      unreadCount: map['unreadCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      clientData: map['clientData'],
      specialistData: map['specialistData'],
    );
  }

  ChatModel copyWith({
    String? id,
    String? clientId,
    String? specialistId,
    String? orderId,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? clientData,
    Map<String, dynamic>? specialistData,
  }) {
    return ChatModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      specialistId: specialistId ?? this.specialistId,
      orderId: orderId ?? this.orderId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      clientData: clientData ?? this.clientData,
      specialistData: specialistData ?? this.specialistData,
    );
  }
}

// Модель сообщения
class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderType; // 'client' или 'specialist'
  final String messageType; // 'text', 'image', 'file', 'system'
  final String content;
  final String? imageUrl;
  final String? fileName;
  final String? fileUrl;
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderType,
    required this.messageType,
    required this.content,
    this.imageUrl,
    this.fileName,
    this.fileUrl,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.replyToMessageId,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderType': senderType,
      'messageType': messageType,
      'content': content,
      'imageUrl': imageUrl,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'replyToMessageId': replyToMessageId,
      'metadata': metadata,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderType: map['senderType'] ?? 'client',
      messageType: map['messageType'] ?? 'text',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      fileName: map['fileName'],
      fileUrl: map['fileUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      isDelivered: map['isDelivered'] ?? false,
      replyToMessageId: map['replyToMessageId'],
      metadata: map['metadata'],
    );
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderType,
    String? messageType,
    String? content,
    String? imageUrl,
    String? fileName,
    String? fileUrl,
    DateTime? timestamp,
    bool? isRead,
    bool? isDelivered,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Вспомогательные методы
  bool get isText => messageType == 'text';
  bool get isImage => messageType == 'image';
  bool get isFile => messageType == 'file';
  bool get isSystem => messageType == 'system';
  bool get isFromClient => senderType == 'client';
  bool get isFromSpecialist => senderType == 'specialist';
}

// Модель для отображения чата в списке
class ChatListItem {
  final String id;
  final String specialistName;
  final String? specialistAvatar;
  final String specialistRole;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? orderId;
  final String? orderService;
  final String? orderStatus;

  ChatListItem({
    required this.id,
    required this.specialistName,
    this.specialistAvatar,
    required this.specialistRole,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.orderId,
    this.orderService,
    this.orderStatus,
  });

  factory ChatListItem.fromChatModel(ChatModel chat, Map<String, dynamic> specialistData) {
    return ChatListItem(
      id: chat.id,
      specialistName: specialistData['name'] ?? 'Специалист',
      specialistAvatar: specialistData['avatarUrl'],
      specialistRole: specialistData['category'] ?? 'Специалист',
      lastMessage: chat.lastMessage,
      lastMessageTime: chat.lastMessageTime,
      unreadCount: chat.unreadCount,
      isOnline: specialistData['isOnline'] ?? false,
      orderId: chat.orderId,
      orderService: specialistData['orderService'],
      orderStatus: specialistData['orderStatus'],
    );
  }
}

// Типы сообщений
enum MessageType {
  text,
  image,
  file,
  system,
}

// Статусы доставки
enum DeliveryStatus {
  sending,
  sent,
  delivered,
  read,
}

// Типы отправителей
enum SenderType {
  client,
  specialist,
  system,
}
