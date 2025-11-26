import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';
import '../../widgets/category_card.dart';
import '../../widgets/specialist_card.dart';
import '../../widgets/search_bar.dart';
import '../../providers/firestore_providers.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../services/test_data_service.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  final _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  // Тестовые баннеры
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Скидка 20% на первый заказ',
      'subtitle': 'Для новых пользователей',
      'color': AppConstants.primaryColor,
      'icon': Icons.local_offer,
    },
    {
      'title': 'Быстрая доставка',
      'subtitle': 'Мастера рядом с вами',
      'color': AppConstants.secondaryColor,
      'icon': Icons.delivery_dining,
    },
    {
      'title': 'Проверенные специалисты',
      'subtitle': 'Все мастера верифицированы',
      'color': AppConstants.successColor,
      'icon': Icons.verified,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Загружаем специалистов при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(specialistsProvider.notifier).loadSpecialists();
    });
    
    // Автопрокрутка баннеров
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _bannerController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Greeting
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingLG),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.primaryLightColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Добро пожаловать! 👋',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppConstants.primaryContrastColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSM),
                    Text(
                      'Найдите лучших специалистов для ваших задач',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppConstants.primaryContrastColor.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Search Bar
              DesignSystemSearchBar(
                hintText: 'Поиск специалистов...',
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
                onSubmitted: (value) {
                  // TODO: Implement search functionality
                },
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Categories Section
              Text(
                'Категории услуг',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppConstants.spacingLG),

              // Categories Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppConstants.spacingMD,
                  mainAxisSpacing: AppConstants.spacingMD,
                  childAspectRatio: 1.2,
                ),
                itemCount: AppConstants.serviceCategories.length,
                itemBuilder: (context, index) {
                  final category = AppConstants.serviceCategories[index];
                  return CategoryCard(
                    id: category['id'],
                    name: category['name'],
                    icon: category['icon'],
                    color: category['color'],
                    emoji: category['emoji'],
                    onTap: () {
                      // TODO: Navigate to category specialists
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Выбрана категория: ${category['name']}'),
                          backgroundColor: AppConstants.primaryColor,
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: AppConstants.spacingXL),

              // Featured Specialists Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Рекомендуемые специалисты',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  DesignSystemButton(
                    text: 'Все',
                    type: ButtonType.ghost,
                    onPressed: () {
                      // TODO: Navigate to all specialists
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingLG),

              // Specialists List
              Consumer(
                builder: (context, ref, child) {
                  final specialistsState = ref.watch(specialistsProvider);
                  
                  if (specialistsState.isLoading) {
                    return _buildLoadingSpecialists();
                  }
                  
                  if (specialistsState.error != null) {
                    return _buildErrorSpecialists(specialistsState.error!);
                  }
                  
                  if (specialistsState.specialists.isEmpty) {
                    return _buildEmptySpecialists();
                  }
                  
                  return Column(
                    children: specialistsState.specialists.take(3).map((specialist) {
                      return SpecialistCard(
                        name: specialist.name,
                        category: specialist.category,
                        location: specialist.location != null 
                            ? '${specialist.location!['lat']?.toStringAsFixed(2)}, ${specialist.location!['lng']?.toStringAsFixed(2)}'
                            : null,
                        rating: specialist.rating,
                        reviewCount: specialist.totalOrders,
                        avatarUrl: specialist.avatarUrl,
                        isFeatured: specialist.isVerified,
                        onTap: () {
                          // TODO: Navigate to specialist profile
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Открыт профиль: ${specialist.name}'),
                              backgroundColor: AppConstants.primaryColor,
                            ),
                          );
                        },
                        onBook: () {
                          // TODO: Navigate to booking
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Заказ для: ${specialist.name}'),
                              backgroundColor: AppConstants.secondaryColor,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: AppConstants.spacingXXL),

              // Quick Actions
              Text(
                'Быстрые действия',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppConstants.spacingLG),

              Row(
                children: [
                  Expanded(
                    child: DesignSystemButton(
                      text: 'Мои заказы',
                      icon: Icons.shopping_bag_outlined,
                      type: ButtonType.secondary,
                      onPressed: () {
                        // TODO: Navigate to orders
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMD),
                  Expanded(
                    child: DesignSystemButton(
                      text: 'Избранное',
                      icon: Icons.favorite_outline,
                      type: ButtonType.secondary,
                      onPressed: () {
                        // TODO: Navigate to favorites
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingXXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySpecialists() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: AppConstants.textSecondary,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'Специалисты не найдены',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Попробуйте изменить параметры поиска',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSpecialists() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            border: Border.all(color: AppConstants.borderColor),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }),
    );
  }

  Widget _buildErrorSpecialists(Object error) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXL),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppConstants.errorColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppConstants.errorColor,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'Ошибка загрузки',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppConstants.errorColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Text(
            'Не удалось загрузить список специалистов',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingLG),
          DesignSystemButton(
            text: 'Повторить',
            type: ButtonType.primary,
            onPressed: () {
              // TODO: Retry loading specialists
            },
          ),
        ],
      ),
    );
  }
}