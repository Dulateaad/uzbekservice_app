import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';

class SpecialistHomeScreen extends ConsumerStatefulWidget {
  const SpecialistHomeScreen({super.key});

  @override
  ConsumerState<SpecialistHomeScreen> createState() => _SpecialistHomeScreenState();
}

class _SpecialistHomeScreenState extends ConsumerState<SpecialistHomeScreen> {
  // Тестовые данные для специалиста
  final Map<String, dynamic> _specialistData = {
    'name': 'Александр Петров',
    'rating': 4.8,
    'totalOrders': 127,
    'completedOrders': 125,
    'cancelledOrders': 2,
    'totalEarnings': 2500000,
    'monthlyEarnings': 450000,
    'isOnline': true,
  };

  final List<Map<String, dynamic>> _newOrders = [
    {
      'id': '1',
      'clientName': 'Иван Иванов',
      'clientPhone': '+998 70 123 45 67',
      'service': 'Мужская стрижка',
      'price': 50000,
      'date': '15 января',
      'time': '14:00',
      'address': 'ул. Амира Темура, 15, Ташкент',
      'comment': 'Классическая стрижка, немного короче сзади',
      'status': 'new',
    },
    {
      'id': '2',
      'clientName': 'Мария Петрова',
      'clientPhone': '+998 70 234 56 78',
      'service': 'Стрижка + борода',
      'price': 80000,
      'date': '16 января',
      'time': '10:00',
      'address': 'ул. Навои, 25, Ташкент',
      'comment': 'Оформление бороды и усов',
      'status': 'new',
    },
  ];

  final List<Map<String, dynamic>> _activeOrders = [
    {
      'id': '3',
      'clientName': 'Дмитрий Козлов',
      'clientPhone': '+998 70 345 67 89',
      'service': 'Детская стрижка',
      'price': 40000,
      'date': 'Сегодня',
      'time': '16:00',
      'address': 'ул. Чилонзар, 8, Ташкент',
      'comment': 'Стрижка для мальчика 5 лет',
      'status': 'in_progress',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppConstants.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spacingMD,
                    50,
                    AppConstants.spacingMD,
                    AppConstants.spacingMD,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          _specialistData['name'][0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMD),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Добро пожаловать,',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              _specialistData['name'],
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Статус онлайн
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingSM,
                          vertical: AppConstants.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: _specialistData['isOnline'] 
                              ? Colors.green 
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                        ),
                        child: Text(
                          _specialistData['isOnline'] ? 'Онлайн' : 'Офлайн',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Основной контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Статистика
                  _buildStatistics(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Новые заказы
                  _buildNewOrders(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Активные заказы
                  _buildActiveOrders(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Быстрые действия
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: AppConstants.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Заказов',
                  '${_specialistData['totalOrders']}',
                  Icons.work_outline,
                  AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: _buildStatCard(
                  'Рейтинг',
                  '${_specialistData['rating']}⭐',
                  Icons.star_outline,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Заработано',
                  '${_specialistData['monthlyEarnings']} сум',
                  Icons.monetization_on_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: _buildStatCard(
                  'Успешность',
                  '${((_specialistData['completedOrders'] / _specialistData['totalOrders']) * 100).round()}%',
                  Icons.check_circle_outline,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNewOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Новые заказы',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_newOrders.isNotEmpty)
              TextButton(
                onPressed: () {
                  context.go('/specialist/orders');
                },
                child: const Text('Все заказы'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        if (_newOrders.isEmpty)
          _buildEmptyState(
            'Нет новых заказов',
            'Новые заказы будут отображаться здесь',
            Icons.shopping_bag_outlined,
          )
        else
          ..._newOrders.map((order) => _buildOrderCard(order, 'new')),
      ],
    );
  }

  Widget _buildActiveOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Активные заказы',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_activeOrders.isNotEmpty)
              TextButton(
                onPressed: () {
                  context.go('/specialist/orders');
                },
                child: const Text('Все заказы'),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        if (_activeOrders.isEmpty)
          _buildEmptyState(
            'Нет активных заказов',
            'Активные заказы будут отображаться здесь',
            Icons.work_outline,
          )
        else
          ..._activeOrders.map((order) => _buildOrderCard(order, 'active')),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: AppConstants.borderColor,
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
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок заказа
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заказ #${order['id']}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingSM,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: type == 'new' 
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    border: Border.all(
                      color: type == 'new' 
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    type == 'new' ? 'Новый' : 'В работе',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: type == 'new' ? Colors.orange : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMD),

            // Информация о клиенте
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                  child: Text(
                    order['clientName'][0].toUpperCase(),
                    style: const TextStyle(
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['clientName'],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        order['clientPhone'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${order['price']} сум',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingMD),

            // Детали заказа
            _buildOrderDetail('Услуга', order['service']),
            _buildOrderDetail('Дата и время', '${order['date']} в ${order['time']}'),
            _buildOrderDetail('Адрес', order['address']),
            if (order['comment'] != null && order['comment'].isNotEmpty)
              _buildOrderDetail('Комментарий', order['comment']),

            const SizedBox(height: AppConstants.spacingMD),

            // Кнопки действий
            if (type == 'new')
              Row(
                children: [
                  Expanded(
                    child: DesignSystemButton(
                      text: 'Отклонить',
                      onPressed: () {
                        _rejectOrder(order);
                      },
                      type: ButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSM),
                  Expanded(
                    child: DesignSystemButton(
                      text: 'Принять',
                      onPressed: () {
                        _acceptOrder(order);
                      },
                      type: ButtonType.primary,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: DesignSystemButton(
                      text: 'Чат с клиентом',
                      onPressed: () {
                        context.go('/specialist/chat/${order['id']}');
                      },
                      type: ButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSM),
                  Expanded(
                    child: DesignSystemButton(
                      text: 'Завершить',
                      onPressed: () {
                        _completeOrder(order);
                      },
                      type: ButtonType.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрые действия',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Мои заказы',
                Icons.work_outline,
                () => context.go('/specialist/orders'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: _buildQuickActionCard(
                'Профиль',
                Icons.person_outline,
                () => context.go('/specialist/profile'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Статистика',
                Icons.analytics_outlined,
                () => context.go('/specialist/analytics'),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: _buildQuickActionCard(
                'Настройки',
                Icons.settings_outlined,
                () => context.go('/specialist/settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 32,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: AppConstants.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppConstants.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _acceptOrder(Map<String, dynamic> order) {
    // TODO: Accept order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Заказ #${order['id']} принят'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectOrder(Map<String, dynamic> order) {
    // TODO: Reject order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Заказ #${order['id']} отклонен'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _completeOrder(Map<String, dynamic> order) {
    // TODO: Complete order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Заказ #${order['id']} завершен'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
