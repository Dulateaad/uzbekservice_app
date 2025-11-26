import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_providers.dart';
import '../../providers/firestore_auth_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  NotificationType? _selectedFilter;
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firestoreAuthProvider);
    final user = authState.user;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);
    final statsAsync = ref.watch(notificationStatsProvider);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(unreadCountAsync),
      body: Column(
        children: [
          _buildStatsCard(statsAsync),
          _buildFilterChips(),
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) => _buildNotificationsList(notifications),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AsyncValue<int> unreadCountAsync) {
    return AppBar(
      backgroundColor: AppConstants.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppConstants.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          const Text(
            'Уведомления',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          unreadCountAsync.when(
            data: (count) => count > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.mark_email_read, color: AppConstants.primaryColor),
          onPressed: () => _markAllAsRead(),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppConstants.textPrimary),
          onPressed: () => _showNotificationSettings(),
        ),
      ],
    );
  }

  Widget _buildStatsCard(Map<String, int> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Всего', stats['total'] ?? 0, Icons.notifications),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppConstants.borderColor,
          ),
          Expanded(
            child: _buildStatItem('Непрочитано', stats['unread'] ?? 0, Icons.mark_email_unread),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppConstants.borderColor,
          ),
          Expanded(
            child: _buildStatItem('Сегодня', stats['today'] ?? 0, Icons.today),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Все', null),
                const SizedBox(width: 8),
                _buildFilterChip('Заказы', NotificationType.orderCreated),
                const SizedBox(width: 8),
                _buildFilterChip('Сообщения', NotificationType.messageReceived),
                const SizedBox(width: 8),
                _buildFilterChip('Платежи', NotificationType.paymentReceived),
                const SizedBox(width: 8),
                _buildFilterChip('Система', NotificationType.system),
              ],
            ),
          ),
          FilterChip(
            label: const Text('Только непрочитанные'),
            selected: _showOnlyUnread,
            onSelected: (selected) {
              setState(() {
                _showOnlyUnread = selected;
              });
            },
            selectedColor: AppConstants.primaryColor.withOpacity(0.2),
            checkmarkColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, NotificationType? type) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? type : null;
        });
      },
      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: AppConstants.primaryColor,
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    // Фильтрация уведомлений
    var filteredNotifications = notifications;
    
    if (_selectedFilter != null) {
      filteredNotifications = notifications.where((n) => n.type == _selectedFilter).toList();
    }
    
    if (_showOnlyUnread) {
      filteredNotifications = filteredNotifications.where((n) => !n.isRead).toList();
    }

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredNotifications.length,
          itemBuilder: (context, index) {
            final notification = filteredNotifications[index];
            return _buildNotificationCard(notification);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? AppConstants.surfaceColor : AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? AppConstants.borderColor : AppConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildNotificationIcon(notification),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
            color: AppConstants.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _formatTime(notification.createdAt),
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                _buildPriorityChip(notification.priority),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleNotificationAction(value, notification),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'read',
              child: Row(
                children: [
                  Icon(
                    notification.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(notification.isRead ? 'Отметить непрочитанным' : 'Отметить прочитанным'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Удалить', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getNotificationColor(notification.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getNotificationColor(notification.type).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        _getNotificationIcon(notification.type),
        color: _getNotificationColor(notification.type),
        size: 24,
      ),
    );
  }

  Widget _buildPriorityChip(NotificationPriority priority) {
    Color color;
    switch (priority) {
      case NotificationPriority.low:
        color = Colors.green;
        break;
      case NotificationPriority.medium:
        color = Colors.orange;
        break;
      case NotificationPriority.high:
        color = Colors.red;
        break;
      case NotificationPriority.urgent:
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.orderCreated:
        return Icons.shopping_bag;
      case NotificationType.orderAccepted:
        return Icons.check_circle;
      case NotificationType.orderCompleted:
        return Icons.done_all;
      case NotificationType.orderCancelled:
        return Icons.cancel;
      case NotificationType.messageReceived:
        return Icons.message;
      case NotificationType.paymentReceived:
        return Icons.payment;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderCreated:
        return Colors.blue;
      case NotificationType.orderAccepted:
        return Colors.green;
      case NotificationType.orderCompleted:
        return Colors.green;
      case NotificationType.orderCancelled:
        return Colors.red;
      case NotificationType.messageReceived:
        return Colors.orange;
      case NotificationType.paymentReceived:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.purple;
      case NotificationType.promotion:
        return Colors.pink;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('dd.MM.yyyy').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'Только что';
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки уведомлений',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(color: AppConstants.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: AppConstants.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет уведомлений',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Здесь будут появляться уведомления о заказах, сообщениях и других событиях',
            style: TextStyle(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      final userId = ref.read(currentUserIdProvider);
      if (userId != null) {
        ref.read(markNotificationAsReadProvider(userId))(notification.id);
      }
    }

    // Навигация по actionUrl если есть
    if (notification.actionUrl != null) {
      context.go(notification.actionUrl!);
    }
  }

  void _handleNotificationAction(String action, NotificationModel notification) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    switch (action) {
      case 'read':
        ref.read(markNotificationAsReadProvider(userId))(notification.id);
        break;
      case 'delete':
        ref.read(deleteNotificationProvider(userId))(notification.id);
        break;
    }
  }

  void _markAllAsRead() {
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      ref.read(markAllNotificationsAsReadProvider(userId))();
    }
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationSettingsSheet(),
    );
  }

  Widget _buildNotificationSettingsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Настройки уведомлений',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingItem(
            'Push уведомления',
            'Получать уведомления на устройство',
            true,
            (value) {},
          ),
          _buildSettingItem(
            'Звук',
            'Звуковое сопровождение уведомлений',
            true,
            (value) {},
          ),
          _buildSettingItem(
            'Вибрация',
            'Вибрация при получении уведомлений',
            true,
            (value) {},
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Сохранить',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
      ),
    );
  }
}