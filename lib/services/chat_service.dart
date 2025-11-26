import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';
import '../models/firestore_models.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';
  static const String _usersCollection = 'users';

  // Создать новый чат
  static Future<String> createChat({
    required String clientId,
    required String specialistId,
    String? orderId,
  }) async {
    try {
      // Проверяем, существует ли уже чат между этими пользователями
      final existingChat = await _firestore
          .collection(_chatsCollection)
          .where('clientId', isEqualTo: clientId)
          .where('specialistId', isEqualTo: specialistId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (existingChat.docs.isNotEmpty) {
        return existingChat.docs.first.id;
      }

      // Получаем данные пользователей
      final clientData = await _getUserData(clientId);
      final specialistData = await _getUserData(specialistId);

      // Создаем новый чат
      final chatRef = _firestore.collection(_chatsCollection).doc();
      final chat = ChatModel(
        id: chatRef.id,
        clientId: clientId,
        specialistId: specialistId,
        orderId: orderId,
        lastMessage: 'Чат создан',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        clientData: clientData,
        specialistData: specialistData,
      );

      await chatRef.set(chat.toMap());
      return chatRef.id;
    } catch (e) {
      print('Ошибка создания чата: $e');
      rethrow;
    }
  }

  // Получить список чатов для пользователя
  static Stream<List<ChatListItem>> getChatsForUser(String userId, String userType) {
    try {
      final field = userType == 'client' ? 'clientId' : 'specialistId';
      
      return _firestore
          .collection(_chatsCollection)
          .where(field, isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        List<ChatListItem> chats = [];
        
        for (var doc in snapshot.docs) {
          final chat = ChatModel.fromMap(doc.data());
          final otherUserId = userType == 'client' ? chat.specialistId : chat.clientId;
          final otherUserData = await _getUserData(otherUserId);
          
          chats.add(ChatListItem.fromChatModel(chat, otherUserData));
        }
        
        return chats;
      });
    } catch (e) {
      print('Ошибка получения чатов: $e');
      return Stream.value([]);
    }
  }

  // Получить сообщения чата
  static Stream<List<MessageModel>> getChatMessages(String chatId) {
    try {
      return _firestore
          .collection(_messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      print('Ошибка получения сообщений: $e');
      return Stream.value([]);
    }
  }

  // Отправить сообщение
  static Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderType,
    required String content,
    MessageType messageType = MessageType.text,
    String? imageUrl,
    String? fileName,
    String? fileUrl,
    String? replyToMessageId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageRef = _firestore.collection(_messagesCollection).doc();
      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: senderId,
        senderType: senderType,
        messageType: messageType.name,
        content: content,
        imageUrl: imageUrl,
        fileName: fileName,
        fileUrl: fileUrl,
        timestamp: DateTime.now(),
        isRead: false,
        isDelivered: true,
        replyToMessageId: replyToMessageId,
        metadata: metadata,
      );

      // Сохраняем сообщение
      await messageRef.set(message.toMap());

      // Обновляем последнее сообщение в чате
      await _updateChatLastMessage(chatId, content, DateTime.now());

      // Отправляем push-уведомление (здесь можно интегрировать FCM)
      await _sendPushNotification(chatId, senderId, content);
    } catch (e) {
      print('Ошибка отправки сообщения: $e');
      rethrow;
    }
  }

  // Отметить сообщения как прочитанные
  static Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messages = await _firestore
          .collection(_messagesCollection)
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      // Обновляем счетчик непрочитанных в чате
      await _updateUnreadCount(chatId, userId, 0);
    } catch (e) {
      print('Ошибка отметки сообщений как прочитанных: $e');
    }
  }

  // Удалить чат
  static Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Ошибка удаления чата: $e');
      rethrow;
    }
  }

  // Получить данные пользователя
  static Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data()!;
      }
      return {};
    } catch (e) {
      print('Ошибка получения данных пользователя: $e');
      return {};
    }
  }

  // Обновить последнее сообщение в чате
  static Future<void> _updateChatLastMessage(String chatId, String message, DateTime timestamp) async {
    try {
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': Timestamp.fromDate(timestamp),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Ошибка обновления последнего сообщения: $e');
    }
  }

  // Обновить счетчик непрочитанных сообщений
  static Future<void> _updateUnreadCount(String chatId, String userId, int count) async {
    try {
      await _firestore.collection(_chatsCollection).doc(chatId).update({
        'unreadCount': count,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      print('Ошибка обновления счетчика непрочитанных: $e');
    }
  }

  // Отправить push-уведомление (заглушка)
  static Future<void> _sendPushNotification(String chatId, String senderId, String message) async {
    // Здесь будет интеграция с Firebase Cloud Messaging
    print('Отправка push-уведомления для чата $chatId: $message');
  }

  // Получить общее количество непрочитанных сообщений
  static Stream<int> getTotalUnreadCount(String userId, String userType) {
    try {
      final field = userType == 'client' ? 'clientId' : 'specialistId';
      
      return _firestore
          .collection(_chatsCollection)
          .where(field, isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data()).unreadCount)
            .fold(0, (sum, count) => sum + count);
      });
    } catch (e) {
      print('Ошибка получения общего количества непрочитанных: $e');
      return Stream.value(0);
    }
  }

  // Поиск чатов
  static Stream<List<ChatListItem>> searchChats(String userId, String userType, String query) {
    try {
      return getChatsForUser(userId, userType).map((chats) {
        return chats.where((chat) {
          return chat.specialistName.toLowerCase().contains(query.toLowerCase()) ||
                 chat.lastMessage.toLowerCase().contains(query.toLowerCase()) ||
                 (chat.orderService?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      });
    } catch (e) {
      print('Ошибка поиска чатов: $e');
      return Stream.value([]);
    }
  }

  // Получить информацию о чате (специалист, заказ)
  static Future<Map<String, dynamic>> getChatInfo(String chatId) async {
    try {
      final chatDoc = await _firestore.collection(_chatsCollection).doc(chatId).get();
      if (!chatDoc.exists) {
        throw Exception('Чат не найден');
      }
      
      final chatData = chatDoc.data()!;
      chatData['id'] = chatDoc.id;
      final chat = ChatModel.fromMap(chatData);
      
      // Получаем данные специалиста
      final specialistDoc = await _firestore.collection(_usersCollection).doc(chat.specialistId).get();
      final specialistData = specialistDoc.exists ? specialistDoc.data()! : {};
      
      // Получаем данные заказа, если есть
      FirestoreOrder? order;
      if (chat.orderId != null) {
        final orderDoc = await _firestore.collection('orders').doc(chat.orderId).get();
        if (orderDoc.exists) {
          final orderData = orderDoc.data()!;
          orderData['id'] = orderDoc.id;
          order = FirestoreOrder.fromMap(orderData);
        }
      }
      
      return {
        'chat': chat.toMap(),
        'specialist': specialistData,
        'order': order?.toMap(),
      };
    } catch (e) {
      print('Ошибка получения информации о чате: $e');
      rethrow;
    }
  }
}
