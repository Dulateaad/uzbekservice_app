import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';

class EnhancedMapsScreen extends ConsumerStatefulWidget {
  const EnhancedMapsScreen({super.key});

  @override
  ConsumerState<EnhancedMapsScreen> createState() => _EnhancedMapsScreenState();
}

class _EnhancedMapsScreenState extends ConsumerState<EnhancedMapsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String _selectedCategory = 'all';
  String _selectedSort = 'distance';
  bool _showFilters = false;
  bool _isMapMode = true;

  final List<String> _categories = ['all', 'barber', 'cleaning', 'plumber', 'electrician', 'nanny'];
  final Map<String, String> _categoryLabels = {
    'all': 'Все',
    'barber': 'Парикмахер',
    'cleaning': 'Уборка',
    'plumber': 'Сантехник',
    'electrician': 'Электрик',
    'nanny': 'Няня',
  };

  final List<String> _sortOptions = ['distance', 'rating', 'price', 'availability'];
  final Map<String, String> _sortLabels = {
    'distance': 'По расстоянию',
    'rating': 'По рейтингу',
    'price': 'По цене',
    'availability': 'По доступности',
  };

  // Тестовые данные специалистов
  final List<Map<String, dynamic>> _specialists = [
    {
      'id': '1',
      'name': 'Александр Петров',
      'category': 'barber',
      'rating': 4.8,
      'reviews': 127,
      'price': 50000,
      'distance': 0.5,
      'isAvailable': true,
      'isOnline': true,
      'avatar': null,
      'services': ['Мужская стрижка', 'Укладка', 'Бритье'],
      'location': {'lat': 41.3111, 'lng': 69.2797},
      'address': 'ул. Амира Темура, 15, Ташкент',
    },
    {
      'id': '2',
      'name': 'Мария Иванова',
      'category': 'cleaning',
      'rating': 4.6,
      'reviews': 89,
      'price': 80000,
      'distance': 1.2,
      'isAvailable': true,
      'isOnline': false,
      'avatar': null,
      'services': ['Уборка квартиры', 'Генеральная уборка', 'Мытье окон'],
      'location': {'lat': 41.3151, 'lng': 69.2857},
      'address': 'ул. Навои, 25, Ташкент',
    },
    {
      'id': '3',
      'name': 'Дмитрий Козлов',
      'category': 'plumber',
      'rating': 4.9,
      'reviews': 203,
      'price': 120000,
      'distance': 0.8,
      'isAvailable': false,
      'isOnline': true,
      'avatar': null,
      'services': ['Ремонт кранов', 'Установка сантехники', 'Прочистка труб'],
      'location': {'lat': 41.3081, 'lng': 69.2757},
      'address': 'ул. Чилонзар, 8, Ташкент',
    },
    {
      'id': '4',
      'name': 'Анна Смирнова',
      'category': 'nanny',
      'rating': 4.7,
      'reviews': 156,
      'price': 150000,
      'distance': 2.1,
      'isAvailable': true,
      'isOnline': true,
      'avatar': null,
      'services': ['Няня на день', 'Присмотр за детьми', 'Развивающие игры'],
      'location': {'lat': 41.3201, 'lng': 69.2907},
      'address': 'ул. Мирабад, 12, Ташкент',
    },
    {
      'id': '5',
      'name': 'Игорь Волков',
      'category': 'electrician',
      'rating': 4.5,
      'reviews': 78,
      'price': 200000,
      'distance': 1.5,
      'isAvailable': true,
      'isOnline': false,
      'avatar': null,
      'services': ['Установка розеток', 'Ремонт проводки', 'Установка кондиционера'],
      'location': {'lat': 41.3251, 'lng': 69.2957},
      'address': 'ул. Юнусабад, 45, Ташкент',
    },
  ];

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
      body: Stack(
        children: [
          // Карта (заглушка)
          _buildMapPlaceholder(),
          
          // Верхняя панель
          _buildTopPanel(),
          
          // Панель поиска
          _buildSearchPanel(),
          
          // Фильтры
          if (_showFilters) _buildFiltersPanel(),
          
          // Список специалистов
          _buildSpecialistsList(),
          
          // Кнопка переключения режима
          _buildToggleButton(),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor.withOpacity(0.1),
            AppConstants.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: AppConstants.primaryColor.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Карта специалистов',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Здесь будет отображаться интерактивная карта',
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.surfaceColor.withOpacity(0.95),
              AppConstants.surfaceColor.withOpacity(0.8),
              Colors.transparent,
            ],
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
                  style: IconButton.styleFrom(
                    backgroundColor: AppConstants.surfaceColor,
                    foregroundColor: AppConstants.textPrimary,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Заголовок
                Expanded(
                  child: Text(
                    'Карта специалистов',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Кнопки действий
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(_showFilters ? Icons.close : Icons.filter_list),
                      style: IconButton.styleFrom(
                        backgroundColor: AppConstants.surfaceColor,
                        foregroundColor: AppConstants.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showSortOptions();
                      },
                      icon: const Icon(Icons.sort),
                      style: IconButton.styleFrom(
                        backgroundColor: AppConstants.surfaceColor,
                        foregroundColor: AppConstants.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppConstants.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Поиск специалистов...',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.my_location,
                  color: AppConstants.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 140,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Категории',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(_categoryLabels[category]!),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                      checkmarkColor: AppConstants.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistsList() {
    final filteredSpecialists = _getFilteredSpecialists();
    
    return Positioned(
      bottom: 100, // Отступ снизу для навигации
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Индикатор
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppConstants.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Заголовок списка
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Специалисты рядом',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${filteredSpecialists.length} найдено',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Список специалистов
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredSpecialists.length,
                itemBuilder: (context, index) {
                  final specialist = filteredSpecialists[index];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.9 + (0.1 * value),
                        child: Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSpecialistCard(specialist),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(Map<String, dynamic> specialist) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go('/home/specialist/${specialist['id']}');
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          child: Row(
            children: [
              // Аватар
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    backgroundImage: specialist['avatar'] != null
                        ? NetworkImage(specialist['avatar'])
                        : null,
                    child: specialist['avatar'] == null
                        ? Text(
                            specialist['name'][0].toUpperCase(),
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (specialist['isOnline'])
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              // Информация о специалисте
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            specialist['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: specialist['isAvailable'] 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            specialist['isAvailable'] ? 'Доступен' : 'Занят',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: specialist['isAvailable'] ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
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
                          '${specialist['rating']} (${specialist['reviews']})',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppConstants.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${specialist['distance']} км',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '${specialist['price'].toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      )} сум/час',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Кнопка действия
              IconButton(
                onPressed: () {
                  _showSpecialistActions(specialist);
                },
                icon: const Icon(Icons.more_vert),
                color: AppConstants.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.4 + 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _isMapMode = !_isMapMode;
              });
            },
            backgroundColor: AppConstants.primaryColor,
            child: Icon(
              _isMapMode ? Icons.list : Icons.map,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredSpecialists() {
    List<Map<String, dynamic>> specialists = List.from(_specialists);
    
    // Фильтрация по категории
    if (_selectedCategory != 'all') {
      specialists = specialists.where((s) => s['category'] == _selectedCategory).toList();
    }
    
    // Сортировка
    switch (_selectedSort) {
      case 'distance':
        specialists.sort((a, b) => a['distance'].compareTo(b['distance']));
        break;
      case 'rating':
        specialists.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'price':
        specialists.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'availability':
        specialists.sort((a, b) => b['isAvailable'].toString().compareTo(a['isAvailable'].toString()));
        break;
    }
    
    return specialists;
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
              
              ..._sortOptions.map((option) {
                final isSelected = _selectedSort == option;
                return ListTile(
                  title: Text(_sortLabels[option]!),
                  trailing: isSelected ? const Icon(Icons.check, color: AppConstants.primaryColor) : null,
                  onTap: () {
                    setState(() {
                      _selectedSort = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSpecialistActions(Map<String, dynamic> specialist) {
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
                specialist['name'],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Написать сообщение'),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/home/chat/specialist_${specialist['id']}');
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Позвонить'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать звонок
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Добавить в избранное'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать добавление в избранное
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Поделиться'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать поделиться
                },
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
