import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';
import '../../providers/chat_providers.dart';
import '../../models/chat_models.dart';

class ModernChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ModernChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ModernChatScreen> createState() => _ModernChatScreenState();
}

class _ModernChatScreenState extends ConsumerState<ModernChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _typingController;
  late AnimationController _messageController;
  late Animation<double> _typingAnimation;
  late Animation<double> _messageAnimation;
  
  bool _isTyping = false;
  bool _showOrderInfo = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollToBottom();
    
    // Отмечаем сообщения как прочитанные при открытии чата
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(userIdProvider);
      if (userId != null) {
        ref.read(markAsReadProvider({
          'chatId': widget.chatId,
          'userId': userId,
        }));
      }
    });
  }

  void _initializeAnimations() {
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    _messageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOutCubic,
    ));

    _messageController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = ref.read(userIdProvider);
    final userType = ref.read(userTypeProvider);
    
    if (userId == null) return;

    // Отправляем сообщение через провайдер
    ref.read(sendMessageProvider({
      'chatId': widget.chatId,
      'senderId': userId,
      'senderType': userType,
      'content': text,
      'messageType': 'text',
    }));

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Кастомный AppBar
            _buildCustomAppBar(),
            
            // Информация о заказе (если есть)
            if (_showOrderInfo) _buildOrderInfo(),
            
            // Список сообщений
            Expanded(
              child: messagesAsync.when(
                data: (messages) => _buildMessagesList(messages),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
            
            // Индикатор печати
            if (_isTyping) _buildTypingIndicator(),
            
            // Поле ввода сообщения
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Кнопка назад
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          
          // Аватар специалиста
          CircleAvatar(
            radius: 20,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              color: AppConstants.primaryColor,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Информация о специалисте
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Александр Петров',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Онлайн',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Кнопки действий
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showOrderInfo = !_showOrderInfo;
                  });
                },
                icon: const Icon(Icons.info_outline),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Показать меню
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_outline,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Мужская стрижка',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppConstants.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '15 января в 14:00',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppConstants.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ул. Амира Темура, 15, Ташкент',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Загружаем сообщения...',
            style: TextStyle(
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки сообщений',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<MessageModel> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message, int index) {
    final isFromCurrentUser = message.senderType == ref.read(userTypeProvider);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: isFromCurrentUser 
                    ? MainAxisAlignment.end 
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isFromCurrentUser) ...[
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      child: Text(
                        'А',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isFromCurrentUser
                            ? AppConstants.primaryColor
                            : AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomLeft: isFromCurrentUser 
                              ? const Radius.circular(20)
                              : const Radius.circular(4),
                          bottomRight: isFromCurrentUser 
                              ? const Radius.circular(4)
                              : const Radius.circular(20),
                        ),
                        border: isFromCurrentUser
                            ? null
                            : Border.all(
                                color: AppConstants.borderColor,
                                width: 1,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.isSystem) ...[
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppConstants.textSecondary,
                            ),
                            const SizedBox(height: 4),
                          ],
                          
                          Text(
                            message.content,
                            style: TextStyle(
                              fontSize: 16,
                              color: isFromCurrentUser
                                  ? Colors.white
                                  : AppConstants.textPrimary,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isFromCurrentUser
                                      ? Colors.white.withOpacity(0.7)
                                      : AppConstants.textSecondary,
                                ),
                              ),
                              if (isFromCurrentUser) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  message.isRead
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 16,
                                  color: message.isRead
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (isFromCurrentUser) ...[
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      backgroundImage: ref.read(currentUserProvider)?.avatarUrl != null
                          ? NetworkImage(ref.read(currentUserProvider)!.avatarUrl!)
                          : null,
                      child: ref.read(currentUserProvider)?.avatarUrl == null
                          ? Text(
                              ref.read(currentUserProvider)?.name?.isNotEmpty == true
                                  ? ref.read(currentUserProvider)!.name![0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                            )
                          : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppConstants.primaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Начните общение',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Отправьте первое сообщение специалисту',
            style: TextStyle(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: Text(
              'А',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConstants.borderColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(
                              0.3 + (0.7 * ((_typingAnimation.value + index * 0.3) % 1.0)),
                            ),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Кнопка прикрепления
            IconButton(
              onPressed: () {
                // TODO: Показать меню прикрепления
              },
              icon: Icon(
                Icons.attach_file,
                color: AppConstants.primaryColor,
              ),
            ),
            
            // Поле ввода
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppConstants.borderColor,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Напишите сообщение...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    // TODO: Отправлять индикатор печати
                  },
                  onSubmitted: (value) {
                    _sendMessage();
                  },
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Кнопка отправки
            Container(
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.day}.${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

