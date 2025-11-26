import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';
import '../../widgets/specialist_card.dart';
import '../../providers/firestore_providers.dart';
import '../../services/test_data_service.dart';
import '../../models/firestore_models.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _staggerAnimation;

  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'all',
    'barber',
    'massage',
    'cleaning',
    'plumber',
    'electrician',
    'nanny',
    'cook',
    'driver',
  ];

  final Map<String, String> _filterLabels = {
    'all': 'Все',
    'barber': 'Барберы',
    'massage': 'Массажисты',
    'cleaning': 'Уборщицы',
    'plumber': 'Сантехники',
    'electrician': 'Электрики',
    'nanny': 'Няни',
    'cook': 'Повара',
    'driver': 'Водители',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFavorites();
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

  void _loadFavorites() {
    // TODO: Загрузить избранные специалисты из Firebase
    // Пока что используем тестовые данные
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
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
            
            // Поиск и фильтры
            _buildSearchAndFilters(),
            
            // Список избранных
            Expanded(
              child: _buildFavoritesList(),
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
                      'Избранное',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Сохраненные специалисты',
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
                      _showSortOptions();
                    },
                    icon: const Icon(Icons.sort),
                  ),
                  IconButton(
                    onPressed: () {
                      _showFilterOptions();
                    },
                    icon: const Icon(Icons.filter_list),
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
                  hintText: 'Поиск специалистов...',
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

  Widget _buildFavoritesList() {
    // TODO: Получить избранных специалистов из Firebase
    final List<FirestoreUser> favorites = TestDataService.getTestSpecialists().where((specialist) {
      if (_selectedFilter != 'all' && specialist.category != _selectedFilter) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final name = specialist.name.toLowerCase();
        final category = (specialist.category ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || category.contains(query);
      }

      return true;
    }).toList();

    if (favorites.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final specialist = favorites[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: Opacity(
                    opacity: value,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SpecialistCard(
                            name: specialist.name,
                            category: specialist.category,
                            location: specialist.location != null
                                ? 'Ташкент'
                                : null,
                            rating: specialist.rating,
                            reviewCount: specialist.totalOrders,
                            avatarUrl: specialist.avatarUrl,
                            isFeatured: (specialist.rating ?? 0) >= 4.8,
                            onTap: () => context.go('/home/specialist/${specialist.id}'),
                            onBook: () => context.go('/home/booking/service-selection/${specialist.id}'),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 24,
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              splashRadius: 20,
                              onPressed: () => _removeFromFavorites(specialist.id),
                              icon: const Icon(Icons.favorite, color: Colors.red),
                            ),
                          ),
                        ),
                      ],
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
                    Icons.favorite_border,
                    size: 60,
                    color: AppConstants.primaryColor.withOpacity(0.6),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  _searchQuery.isNotEmpty || _selectedFilter != 'all'
                      ? 'Ничего не найдено'
                      : 'Пока нет избранных',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _searchQuery.isNotEmpty || _selectedFilter != 'all'
                      ? 'Попробуйте изменить фильтры или поисковый запрос'
                      : 'Добавьте специалистов в избранное,\nчтобы быстро найти их позже',
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                if (_searchQuery.isNotEmpty || _selectedFilter != 'all')
                  DesignSystemButton(
                    text: 'Сбросить фильтры',
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedFilter = 'all';
                        _searchController.clear();
                      });
                    },
                    type: ButtonType.primary,
                  )
                else
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
              
              _buildSortOption('name', 'По имени', Icons.sort_by_alpha),
              _buildSortOption('rating', 'По рейтингу', Icons.star),
              _buildSortOption('price', 'По цене', Icons.attach_money),
              _buildSortOption('distance', 'По расстоянию', Icons.location_on),
              
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

  void _removeFromFavorites(String specialistId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить из избранного'),
        content: const Text('Вы уверены, что хотите удалить этого специалиста из избранного?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Удалить из Firebase
              setState(() {
                // Обновить локальное состояние
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Специалист удален из избранного'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
