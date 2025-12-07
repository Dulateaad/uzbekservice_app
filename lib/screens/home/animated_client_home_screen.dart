import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';
import '../../widgets/category_card.dart';
import '../../widgets/specialist_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/top_specialist_card.dart';
import '../../providers/firestore_providers.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../providers/chat_providers.dart';
import '../../services/test_data_service.dart';

class AnimatedClientHomeScreen extends ConsumerStatefulWidget {
  const AnimatedClientHomeScreen({super.key});

  @override
  ConsumerState<AnimatedClientHomeScreen> createState() => _AnimatedClientHomeScreenState();
}

class _AnimatedClientHomeScreenState extends ConsumerState<AnimatedClientHomeScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    // Загружаем специалистов при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(specialistsProvider.notifier).loadSpecialists();
    });
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeInOut,
    ));

    // Запускаем анимации
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firestoreAuthProvider);
    final userName = authState.user?.name ?? 'Пользователь';
    final userType = ref.watch(userTypeProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider(userType));
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Анимированный AppBar
            _buildAnimatedAppBar(userName, unreadCountAsync),
            
            // Основной контент
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Поиск с анимацией
                    _buildAnimatedSearchBar(),
                    
                    const SizedBox(height: AppConstants.spacingLG),
                    
                    // Карусель баннеров с анимацией
                    _buildAnimatedBannerCarousel(),
                    
                    const SizedBox(height: AppConstants.spacingLG),
                    
                    // Категории с анимацией
                    _buildAnimatedCategoriesSection(),
                    
                    const SizedBox(height: AppConstants.spacingLG),
                    
                    // Топ специалисты с анимацией
                    _buildAnimatedTopSpecialistsSection(),
                    
                    const SizedBox(height: AppConstants.spacingLG),
                    
                    // Рекомендуемые специалисты с анимацией
                    _buildAnimatedRecommendedSpecialistsSection(),
                    
                    const SizedBox(height: AppConstants.spacingLG),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar(String userName, AsyncValue<int> unreadCountAsync) {
    return SliverAppBar(
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
                AppConstants.primaryColor.withOpacity(0.9),
                AppConstants.primaryColor.withOpacity(0.8),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Декоративные элементы
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              
              // Основной контент
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Привет, $userName! 👋',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Что вам нужно сегодня?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Кнопки действий
                        Row(
                          children: [
                            // Уведомления
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // TODO: Показать уведомления
                                  },
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                unreadCountAsync.when(
                                  data: (count) => count > 0
                                      ? Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              count > 99 ? '99+' : count.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            
                            // Чаты
                            IconButton(
                              onPressed: () {
                                context.go('/home/chat');
                              },
                              icon: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSearchBar() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск специалистов...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppConstants.primaryColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // TODO: Показать фильтры
                    },
                    icon: Icon(
                      Icons.tune,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.go('/home/search?query=$value');
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBannerCarousel() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: BannerCarousel(banners: const []),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Категории',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/home/categories');
                      },
                      child: const Text('Все'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.9 + (0.1 * value),
              child: Opacity(
                opacity: value,
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.serviceCategories.length,
                    itemBuilder: (context, index) {
                      final category = AppConstants.serviceCategories[index];
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Opacity(
                              opacity: value,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: CategoryCard(
                                  id: category['id'] as String,
                                  name: category['name'] as String,
                                  icon: category['icon'] as IconData,
                                  color: category['color'] as Color,
                                  onTap: () {
                                    context.go('/home/category/${category['id']}');
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedTopSpecialistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Топ специалисты',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/home/specialists?filter=top');
                      },
                      child: const Text('Все'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.9 + (0.1 * value),
              child: Opacity(
                opacity: value,
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3, // Показываем только 3 топ специалиста
                    itemBuilder: (context, index) {
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 500 + (index * 150)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: Opacity(
                              opacity: value,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: TopSpecialistCard(
                                  specialist: TestDataService.getTestSpecialists()[index],
                                  onTap: () {
                                    context.go('/home/specialist/${TestDataService.getTestSpecialists()[index].id}');
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedRecommendedSpecialistsSection() {
    final specialistsAsync = ref.watch(specialistsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Рекомендуемые',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/home/specialists');
                      },
                      child: const Text('Все'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.9 + (0.1 * value),
              child: Opacity(
                opacity: value,
                child: specialistsAsync.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : specialistsAsync.error != null
                        ? Center(child: Text('Ошибка загрузки: ${specialistsAsync.error}'))
                        : specialistsAsync.specialists.isEmpty
                            ? const Center(child: Text('Нет специалистов'))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: specialistsAsync.specialists.length > 3 ? 3 : specialistsAsync.specialists.length,
                                itemBuilder: (context, index) {
                                  final specialist = specialistsAsync.specialists[index];
                                  return TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 600 + (index * 100)),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 30 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: SpecialistCard(
                                              name: specialist.name,
                                              category: specialist.category,
                                              location: specialist.location != null 
                                                  ? '${specialist.location!['lat']}, ${specialist.location!['lng']}'
                                                  : null,
                                              rating: specialist.rating,
                                              reviewCount: specialist.totalOrders,
                                              avatarUrl: specialist.avatarUrl,
                                              onTap: () {
                                                context.go('/home/specialist/${specialist.id}');
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingSpecialists() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            border: Border.all(
              color: AppConstants.borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorSpecialists(Object error) {
    return Container(
      padding: const EdgeInsets.all(32),
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
            Icons.error_outline,
            size: 48,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки специалистов',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          const SizedBox(height: 16),
          DesignSystemButton(
            text: 'Попробовать снова',
            onPressed: () {
              ref.read(specialistsProvider.notifier).loadSpecialists();
            },
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }
}
