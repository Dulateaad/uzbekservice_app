import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';
import '../../providers/chat_providers.dart';

class AnimatedOrdersScreen extends ConsumerStatefulWidget {
  const AnimatedOrdersScreen({super.key});

  @override
  ConsumerState<AnimatedOrdersScreen> createState() => _AnimatedOrdersScreenState();
}

class _AnimatedOrdersScreenState extends ConsumerState<AnimatedOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _staggerAnimation;

  int _currentTabIndex = 0;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['all', 'confirmed', 'in_progress', 'completed', 'cancelled'];
  final Map<String, String> _filterLabels = {
    'all': 'Все',
    'confirmed': 'Подтверждены',
    'in_progress': 'В работе',
    'completed': 'Завершены',
    'cancelled': 'Отменены',
  };

  // Тестовые данные заказов
  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': '1',
      'specialistName': 'Александр Петров',
      'specialistAvatar': null,
      'service': 'Мужская стрижка',
      'price': 50000,
      'date': '2024-01-15',
      'time': '14:00',
      'address': 'ул. Амира Темура, 15, Ташкент',
      'status': 'confirmed',
      'statusText': 'Подтвержден',
      'statusColor': Colors.green,
      'category': 'barber',
    },
    {
      'id': '2',
      'specialistName': 'Мария Иванова',
      'specialistAvatar': null,
      'service': 'Уборка квартиры',
      'price': 80000,
      'date': '2024-01-16',
      'time': '10:00',
      'address': 'ул. Навои, 25, Ташкент',
      'status': 'in_progress',
      'statusText': 'В работе',
      'statusColor': Colors.blue,
      'category': 'cleaning',
    },
    {
      'id': '3',
      'specialistName': 'Дмитрий Козлов',
      'specialistAvatar': null,
      'service': 'Ремонт крана',
      'price': 120000,
      'date': '2024-01-10',
      'time': '16:00',
      'address': 'ул. Чилонзар, 8, Ташкент',
      'status': 'completed',
      'statusText': 'Завершен',
      'statusColor': Colors.green,
      'rating': 5,
      'category': 'plumber',
    },
    {
      'id': '4',
      'specialistName': 'Анна Смирнова',
      'specialistAvatar': null,
      'service': 'Няня на день',
      'price': 150000,
      'date': '2024-01-08',
      'time': '09:00',
      'address': 'ул. Мирабад, 12, Ташкент',
      'status': 'completed',
      'statusText': 'Завершен',
      'statusColor': Colors.green,
      'rating': 4,
      'category': 'nanny',
    },
    {
      'id': '5',
      'specialistName': 'Игорь Волков',
      'specialistAvatar': null,
      'service': 'Установка кондиционера',
      'price': 200000,
      'date': '2024-01-05',
      'time': '11:00',
      'address': 'ул. Юнусабад, 45, Ташкент',
      'status': 'cancelled',
      'statusText': 'Отменен',
      'statusColor': Colors.red,
      'cancellationReason': 'Специалист не смог приехать',
      'category': 'electrician',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userType = ref.watch(userTypeProvider);
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Кастомный AppBar
            _buildCustomAppBar(),
            
            // Поиск и фильтры
            _buildSearchAndFilters(),
            
            // Табы
            _buildTabs(),
            
            // Список заказов
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100), // Отступ снизу для навигации
                child: _buildOrdersList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Row(
            children: [
              // Кнопка назад
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              
              // Заголовок
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Заказы',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Управление заказами',
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Кнопки действий
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _showFilterOptions();
                    },
                    icon: const Icon(Icons.filter_list),
                  ),
                  IconButton(
                    onPressed: () {
                      _showSortOptions();
                    },
                    icon: const Icon(Icons.sort),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Поиск
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск заказов...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                    borderSide: BorderSide(color: AppConstants.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                    borderSide: BorderSide(color: AppConstants.primaryColor),
                  ),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Фильтры
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_filterLabels[filter]!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppConstants.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppConstants.primaryColor : AppConstants.borderColor,
                          width: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: AppConstants.borderColor,
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        indicator: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppConstants.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Активные'),
          Tab(text: 'Завершенные'),
          Tab(text: 'Отмененные'),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    final orders = _getFilteredOrders();
    
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildOrderCard(order),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: AppConstants.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с статусом
          Row(
            children: [
              Expanded(
                child: Text(
                  order['service'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: order['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                  border: Border.all(
                    color: order['statusColor'].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  order['statusText'],
                  style: TextStyle(
                    color: order['statusColor'],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Информация о специалисте
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                backgroundImage: order['specialistAvatar'] != null
                    ? NetworkImage(order['specialistAvatar'])
                    : null,
                child: order['specialistAvatar'] == null
                    ? Text(
                        order['specialistName'][0].toUpperCase(),
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['specialistName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      order['address'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Детали заказа
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppConstants.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${order['date']} в ${order['time']}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${order['price'].toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                )} сум',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          
          if (order['rating'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  '${order['rating']}/5',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Кнопки действий
          _buildActionButtons(order),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    switch (order['status']) {
      case 'confirmed':
      case 'in_progress':
        return Row(
          children: [
            Expanded(
              child: DesignSystemButton(
                text: 'Отменить',
                onPressed: () {
                  _showCancelDialog(order);
                },
                type: ButtonType.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DesignSystemButton(
                text: 'Чат',
                onPressed: () {
                  context.go('/home/chat/${order['id']}');
                },
                type: ButtonType.primary,
              ),
            ),
          ],
        );
      case 'completed':
        return Row(
          children: [
            Expanded(
              child: DesignSystemButton(
                text: 'Повторить',
                onPressed: () {
                  _repeatOrder(order);
                },
                type: ButtonType.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DesignSystemButton(
                text: 'Отзыв',
                onPressed: () {
                  _leaveReview(order);
                },
                type: ButtonType.primary,
              ),
            ),
          ],
        );
      case 'cancelled':
        return DesignSystemButton(
          text: 'Заказать снова',
          onPressed: () {
            _orderAgain(order);
          },
          type: ButtonType.primary,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 60,
                    color: AppConstants.primaryColor.withOpacity(0.6),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  _getEmptyStateTitle(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _getEmptyStateSubtitle(),
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                DesignSystemButton(
                  text: 'Найти специалистов',
                  onPressed: () {
                    context.go('/home');
                  },
                  type: ButtonType.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEmptyStateTitle() {
    switch (_currentTabIndex) {
      case 0:
        return 'Нет активных заказов';
      case 1:
        return 'Нет завершенных заказов';
      case 2:
        return 'Нет отмененных заказов';
      default:
        return 'Нет заказов';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (_currentTabIndex) {
      case 0:
        return 'Создайте заказ, чтобы увидеть его здесь';
      case 1:
        return 'Завершенные заказы появятся здесь';
      case 2:
        return 'Отмененные заказы появятся здесь';
      default:
        return 'Заказы появятся здесь';
    }
  }

  List<Map<String, dynamic>> _getFilteredOrders() {
    List<Map<String, dynamic>> orders = [];
    
    switch (_currentTabIndex) {
      case 0:
        orders = _allOrders.where((order) => 
          order['status'] == 'confirmed' || order['status'] == 'in_progress').toList();
        break;
      case 1:
        orders = _allOrders.where((order) => order['status'] == 'completed').toList();
        break;
      case 2:
        orders = _allOrders.where((order) => order['status'] == 'cancelled').toList();
        break;
    }
    
    // Фильтрация по статусу
    if (_selectedFilter != 'all') {
      orders = orders.where((order) => order['status'] == _selectedFilter).toList();
    }
    
    // Поиск
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) {
        final service = order['service'].toLowerCase();
        final specialist = order['specialistName'].toLowerCase();
        final address = order['address'].toLowerCase();
        final query = _searchQuery.toLowerCase();
        return service.contains(query) || 
               specialist.contains(query) || 
               address.contains(query);
      }).toList();
    }
    
    return orders;
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              Text(
                'Фильтры',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Дополнительные фильтры
              _buildFilterOption('verified', 'Только верифицированные', Icons.verified),
              _buildFilterOption('online', 'Только онлайн', Icons.circle),
              _buildFilterOption('nearby', 'Рядом со мной', Icons.location_on),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String value, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(label),
      trailing: Switch(
        value: false, // TODO: Получить из состояния
        onChanged: (value) {
          // TODO: Применить фильтр
        },
        activeColor: AppConstants.primaryColor,
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
              Text(
                'Сортировка',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSortOption('date', 'По дате', Icons.calendar_today),
              _buildSortOption('price', 'По цене', Icons.attach_money),
              _buildSortOption('status', 'По статусу', Icons.flag),
              _buildSortOption('specialist', 'По специалисту', Icons.person),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // TODO: Применить сортировку
      },
    );
  }

  void _showCancelDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить заказ'),
        content: const Text('Вы уверены, что хотите отменить этот заказ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Отменить заказ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Заказ отменен'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Отменить'),
          ),
        ],
      ),
    );
  }

  void _repeatOrder(Map<String, dynamic> order) {
    // TODO: Повторить заказ
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заказ добавлен в корзину'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _leaveReview(Map<String, dynamic> order) {
    // TODO: Оставить отзыв
    context.go('/home/review/${order['id']}');
  }

  void _orderAgain(Map<String, dynamic> order) {
    // TODO: Заказать снова
    context.go('/home/specialist/${order['specialistId']}');
  }
}
