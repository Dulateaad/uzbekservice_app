import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/specialist_card.dart';
import '../../widgets/design_system_button.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  // Тестовые данные для избранных специалистов
  final List<Map<String, dynamic>> _favoriteSpecialists = [
    {
      'id': 'specialist_1',
      'name': 'Азиз Ахмедов',
      'profession': 'Сантехник',
      'rating': 4.9,
      'reviewsCount': 128,
      'price': 150000,
      'avatar': null,
      'isOnline': true,
      'isFavorite': true,
      'category': 'plumbing',
      'experience': '5 лет',
      'location': 'Ташкент, Чилонзар',
      'services': ['Ремонт кранов', 'Установка сантехники', 'Прочистка труб'],
    },
    {
      'id': 'specialist_2',
      'name': 'Марина Петрова',
      'profession': 'Электрик',
      'rating': 4.8,
      'reviewsCount': 95,
      'price': 200000,
      'avatar': null,
      'isOnline': true,
      'isFavorite': true,
      'category': 'electrical',
      'experience': '7 лет',
      'location': 'Ташкент, Мирзо-Улугбек',
      'services': ['Электромонтаж', 'Ремонт проводки', 'Установка розеток'],
    },
    {
      'id': 'specialist_3',
      'name': 'Сергей Иванов',
      'profession': 'Мастер по ремонту',
      'rating': 4.7,
      'reviewsCount': 76,
      'price': 180000,
      'avatar': null,
      'isOnline': false,
      'isFavorite': true,
      'category': 'repair',
      'experience': '4 года',
      'location': 'Ташкент, Сергели',
      'services': ['Ремонт мебели', 'Установка дверей', 'Отделочные работы'],
    },
    {
      'id': 'specialist_4',
      'name': 'Ольга Козлова',
      'profession': 'Уборщица',
      'rating': 4.9,
      'reviewsCount': 203,
      'price': 80000,
      'avatar': null,
      'isOnline': true,
      'isFavorite': true,
      'category': 'cleaning',
      'experience': '3 года',
      'location': 'Ташкент, Шайхантахур',
      'services': ['Генеральная уборка', 'Еженедельная уборка', 'Мытье окон'],
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100), // Отступ снизу для навигации
              child: _buildFavoritesList(),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppConstants.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Избранное',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort, color: AppConstants.primaryColor),
          onPressed: _showSortOptions,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppConstants.textPrimary),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMD),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Поиск избранных специалистов...',
          prefixIcon: const Icon(Icons.search, color: AppConstants.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppConstants.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            borderSide: BorderSide(color: AppConstants.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
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
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'key': 'all', 'label': 'Все', 'icon': Icons.all_inclusive},
      {'key': 'plumbing', 'label': 'Сантехника', 'icon': Icons.plumbing},
      {'key': 'electrical', 'label': 'Электрика', 'icon': Icons.electrical_services},
      {'key': 'repair', 'label': 'Ремонт', 'icon': Icons.build},
      {'key': 'cleaning', 'label': 'Уборка', 'icon': Icons.cleaning_services},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['key'];
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(category['label'] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['key'] as String;
                });
              },
              selectedColor: AppConstants.primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppConstants.textPrimary,
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
    );
  }

  Widget _buildFavoritesList() {
    final filteredSpecialists = _getFilteredSpecialists();
    
    if (filteredSpecialists.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: filteredSpecialists.length,
          itemBuilder: (context, index) {
            return _buildFavoriteCard(filteredSpecialists[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> specialist, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
            child: SpecialistCard(
              name: specialist['name'] as String,
              category: specialist['profession'] as String,
              location: specialist['location'] as String,
              rating: specialist['rating'] as double,
              reviewCount: specialist['reviewsCount'] as int,
              avatarUrl: specialist['avatar'] as String?,
              onTap: () => _navigateToSpecialist(specialist),
              onBook: () => _navigateToSpecialist(specialist),
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
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppConstants.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            _searchQuery.isNotEmpty ? 'Ничего не найдено' : 'Нет избранных специалистов',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Попробуйте изменить поисковый запрос'
                : 'Добавьте специалистов в избранное, чтобы быстро находить их',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppConstants.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: AppConstants.spacingLG),
            DesignSystemButton(
              text: 'Найти специалистов',
              onPressed: () => context.push('/search'),
              icon: Icons.search,
            ),
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredSpecialists() {
    List<Map<String, dynamic>> filtered = List.from(_favoriteSpecialists);
    
    // Фильтр по категории
    if (_selectedCategory != 'all') {
      filtered = filtered.where((specialist) => specialist['category'] == _selectedCategory).toList();
    }
    
    // Фильтр по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((specialist) =>
          specialist['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          specialist['profession'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (specialist['services'] as List).any((service) => 
              service.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }
    
    return filtered;
  }

  void _navigateToSpecialist(Map<String, dynamic> specialist) {
    context.push('/specialist/${specialist['id']}');
  }

  void _toggleFavorite(Map<String, dynamic> specialist) {
    setState(() {
      specialist['isFavorite'] = !specialist['isFavorite'];
      if (!specialist['isFavorite']) {
        _favoriteSpecialists.removeWhere((s) => s['id'] == specialist['id']);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          specialist['isFavorite'] 
              ? 'Добавлено в избранное' 
              : 'Удалено из избранного',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: specialist['isFavorite'] ? null : SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            setState(() {
              specialist['isFavorite'] = true;
              _favoriteSpecialists.add(specialist);
            });
          },
        ),
      ),
    );
  }

  void _callSpecialist(Map<String, dynamic> specialist) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Звонок ${specialist['name']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _chatWithSpecialist(Map<String, dynamic> specialist) {
    context.push('/chat/specialist_${specialist['id']}');
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
              _buildSortOption('rating', 'По рейтингу', Icons.star),
              _buildSortOption('price_low', 'По цене (низкая)', Icons.arrow_upward),
              _buildSortOption('price_high', 'По цене (высокая)', Icons.arrow_downward),
              _buildSortOption('name', 'По имени', Icons.sort_by_alpha),
              _buildSortOption('recent', 'Недавно добавленные', Icons.access_time),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        // TODO: Implement sorting
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Сортировка: $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
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
                'Дополнительно',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildMoreOption('share', 'Поделиться списком', Icons.share),
              _buildMoreOption('export', 'Экспортировать', Icons.download),
              _buildMoreOption('clear', 'Очистить все', Icons.clear_all, isDestructive: true),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoreOption(String value, String title, IconData icon, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon, 
        color: isDestructive ? Colors.red : AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppConstants.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _handleMoreOption(value);
      },
    );
  }

  void _handleMoreOption(String value) {
    switch (value) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Поделиться списком избранного'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Экспорт списка избранного'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'clear':
        _showClearAllDialog();
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все избранное'),
        content: const Text(
          'Вы уверены, что хотите удалить всех специалистов из избранного? '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _favoriteSpecialists.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Все избранное очищено'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
}
