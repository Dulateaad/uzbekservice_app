import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';
import '../../providers/chat_providers.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Тестовые данные заказа
  final Map<String, dynamic> _order = {
    'id': '1',
    'specialistName': 'Александр Петров',
    'specialistAvatar': null,
    'specialistPhone': '+998 90 123 45 67',
    'specialistRating': 4.8,
    'specialistReviews': 127,
    'service': 'Мужская стрижка',
    'description': 'Классическая мужская стрижка с укладкой',
    'price': 50000,
    'date': '2024-01-15',
    'time': '14:00',
    'duration': 60,
    'address': 'ул. Амира Темура, 15, Ташкент',
    'status': 'confirmed',
    'statusText': 'Подтвержден',
    'statusColor': Colors.green,
    'category': 'barber',
    'createdAt': '2024-01-14T10:30:00Z',
    'notes': 'Пожалуйста, подстригите немного короче сзади',
    'images': [
      'https://example.com/image1.jpg',
      'https://example.com/image2.jpg',
    ],
  };

  @override
  void initState() {
    super.initState();
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
    
    _scaleController = AnimationController(
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Кастомный AppBar
            _buildCustomAppBar(),
            
            // Основной контент
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Статус заказа
                        _buildOrderStatus(),
                        
                        const SizedBox(height: 24),
                        
                        // Информация о специалисте
                        _buildSpecialistInfo(),
                        
                        const SizedBox(height: 24),
                        
                        // Детали услуги
                        _buildServiceDetails(),
                        
                        const SizedBox(height: 24),
                        
                        // Время и место
                        _buildTimeAndLocation(),
                        
                        const SizedBox(height: 24),
                        
                        // Дополнительная информация
                        _buildAdditionalInfo(),
                        
                        const SizedBox(height: 24),
                        
                        // Кнопки действий
                        _buildActionButtons(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
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
                      'Детали заказа',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '№${_order['id']}',
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
                      _shareOrder();
                    },
                    icon: const Icon(Icons.share),
                  ),
                  IconButton(
                    onPressed: () {
                      _showMoreOptions();
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _order['statusColor'].withOpacity(0.1),
                    _order['statusColor'].withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                border: Border.all(
                  color: _order['statusColor'].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(),
                    size: 48,
                    color: _order['statusColor'],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _order['statusText'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _order['statusColor'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusDescription(),
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialistInfo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
                  Text(
                    'Специалист',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                        backgroundImage: _order['specialistAvatar'] != null
                            ? NetworkImage(_order['specialistAvatar'])
                            : null,
                        child: _order['specialistAvatar'] == null
                            ? Text(
                                _order['specialistName'][0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              )
                            : null,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _order['specialistName'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_order['specialistRating']} (${_order['specialistReviews']} отзывов)',
                                  style: TextStyle(
                                    color: AppConstants.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _order['specialistPhone'],
                              style: TextStyle(
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      IconButton(
                        onPressed: () {
                          context.go('/home/specialist/${_order['specialistId']}');
                        },
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceDetails() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
                  Text(
                    'Детали услуги',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Название услуги
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _order['service'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${_order['price'].toString().replaceAllMapped(
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
                  
                  const SizedBox(height: 16),
                  
                  // Описание
                  if (_order['description'] != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: AppConstants.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _order['description'],
                            style: TextStyle(
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Длительность
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppConstants.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Длительность: ${_order['duration']} минут',
                        style: TextStyle(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeAndLocation() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
                  Text(
                    'Время и место',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Дата и время
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_order['date']} в ${_order['time']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Адрес
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppConstants.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _order['address'],
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Кнопка "Показать на карте"
                  SizedBox(
                    width: double.infinity,
                    child: DesignSystemButton(
                      text: 'Показать на карте',
                      onPressed: () {
                        _showOnMap();
                      },
                      type: ButtonType.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdditionalInfo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
                  Text(
                    'Дополнительная информация',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Заметки
                  if (_order['notes'] != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          color: AppConstants.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Заметки:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _order['notes'],
                                style: TextStyle(
                                  color: AppConstants.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Дата создания
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: AppConstants.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Создан: ${_formatDate(_order['createdAt'])}',
                        style: TextStyle(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                // Основные кнопки
                Row(
                  children: [
                    Expanded(
                      child: DesignSystemButton(
                        text: 'Чат',
                        onPressed: () {
                          context.go('/home/chat/${_order['id']}');
                        },
                        type: ButtonType.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DesignSystemButton(
                        text: 'Позвонить',
                        onPressed: () {
                          _callSpecialist();
                        },
                        type: ButtonType.secondary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Дополнительные кнопки в зависимости от статуса
                if (_order['status'] == 'confirmed' || _order['status'] == 'in_progress')
                  DesignSystemButton(
                    text: 'Отменить заказ',
                    onPressed: () {
                      _cancelOrder();
                    },
                    type: ButtonType.accent,
                  )
                else if (_order['status'] == 'completed')
                  DesignSystemButton(
                    text: 'Оставить отзыв',
                    onPressed: () {
                      _leaveReview();
                    },
                    type: ButtonType.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getStatusIcon() {
    switch (_order['status']) {
      case 'confirmed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusDescription() {
    switch (_order['status']) {
      case 'confirmed':
        return 'Заказ подтвержден специалистом';
      case 'in_progress':
        return 'Специалист выполняет заказ';
      case 'completed':
        return 'Заказ успешно завершен';
      case 'cancelled':
        return 'Заказ был отменен';
      default:
        return 'Неизвестный статус';
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}.${date.month}.${date.year} в ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _shareOrder() {
    // TODO: Поделиться заказом
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция поделиться будет добавлена'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreOptions() {
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
                'Дополнительные действия',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Скачать чек'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Скачать чек
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Пожаловаться'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Пожаловаться
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showOnMap() {
    // TODO: Показать на карте
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Открытие карты...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _callSpecialist() {
    // TODO: Позвонить специалисту
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Звонок специалисту...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _cancelOrder() {
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

  void _leaveReview() {
    // TODO: Оставить отзыв
    context.go('/home/review/${_order['id']}');
  }
}
