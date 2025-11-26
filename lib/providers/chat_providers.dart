import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import 'firestore_auth_provider.dart';
import '../models/firestore_models.dart';

// Провайдер для списка чатов
final chatsProvider = StreamProvider.family<List<ChatListItem>, String>((ref, userType) {
  final authState = ref.watch(firestoreAuthProvider);
  final userId = authState.user?.id;
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  return ChatService.getChatsForUser(userId, userType);
});

// Провайдер для сообщений конкретного чата
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ChatService.getChatMessages(chatId);
});

// Провайдер для общего количества непрочитанных сообщений
final unreadCountProvider = StreamProvider.family<int, String>((ref, userType) {
  final authState = ref.watch(firestoreAuthProvider);
  final userId = authState.user?.id;
  
  if (userId == null) {
    return Stream.value(0);
  }
  
  return ChatService.getTotalUnreadCount(userId, userType);
});

// Провайдер для поиска чатов
final chatSearchProvider = StreamProvider.family<List<ChatListItem>, Map<String, String>>((ref, params) {
  final userId = params['userId'];
  final userType = params['userType'];
  final query = params['query'] ?? '';
  
  if (userId == null || userType == null) {
    return Stream.value([]);
  }
  
  if (query.isEmpty) {
    return ChatService.getChatsForUser(userId, userType);
  }
  
  return ChatService.searchChats(userId, userType, query);
});

// Провайдер для создания чата
final createChatProvider = FutureProvider.family<String, Map<String, String>>((ref, params) async {
  final clientId = params['clientId'];
  final specialistId = params['specialistId'];
  final orderId = params['orderId'];
  
  if (clientId == null || specialistId == null) {
    throw Exception('Необходимы ID клиента и специалиста');
  }
  
  return ChatService.createChat(
    clientId: clientId,
    specialistId: specialistId,
    orderId: orderId,
  );
});

// Провайдер для отправки сообщения
final sendMessageProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  final chatId = params['chatId'] as String;
  final senderId = params['senderId'] as String;
  final senderType = params['senderType'] as String;
  final content = params['content'] as String;
  final messageType = MessageType.values.firstWhere(
    (e) => e.name == (params['messageType'] as String? ?? 'text'),
    orElse: () => MessageType.text,
  );
  final imageUrl = params['imageUrl'] as String?;
  final fileName = params['fileName'] as String?;
  final fileUrl = params['fileUrl'] as String?;
  final replyToMessageId = params['replyToMessageId'] as String?;
  final metadata = params['metadata'] as Map<String, dynamic>?;
  
  return ChatService.sendMessage(
    chatId: chatId,
    senderId: senderId,
    senderType: senderType,
    content: content,
    messageType: messageType,
    imageUrl: imageUrl,
    fileName: fileName,
    fileUrl: fileUrl,
    replyToMessageId: replyToMessageId,
    metadata: metadata,
  );
});

// Провайдер для отметки сообщений как прочитанных
final markAsReadProvider = FutureProvider.family<void, Map<String, String>>((ref, params) async {
  final chatId = params['chatId'];
  final userId = params['userId'];
  
  if (chatId == null || userId == null) {
    throw Exception('Необходимы ID чата и пользователя');
  }
  
  return ChatService.markMessagesAsRead(chatId, userId);
});

// Провайдер для удаления чата
final deleteChatProvider = FutureProvider.family<void, String>((ref, chatId) async {
  return ChatService.deleteChat(chatId);
});

// Провайдер для текущего пользователя
final currentUserProvider = Provider<FirestoreUser?>((ref) {
  final authState = ref.watch(firestoreAuthProvider);
  return authState.user;
});

// Провайдер для типа пользователя
final userTypeProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userType ?? 'client';
});

// Провайдер для ID пользователя
final userIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});

// Провайдер для получения информации о чате (специалист, заказ)
final chatInfoProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, chatId) async {
  return ChatService.getChatInfo(chatId);
});
