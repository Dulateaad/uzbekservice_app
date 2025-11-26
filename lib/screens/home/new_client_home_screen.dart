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
import '../../services/test_data_service.dart';

class NewClientHomeScreen extends ConsumerStatefulWidget {
  const NewClientHomeScreen({super.key});

  @override
  ConsumerState<NewClientHomeScreen> createState() => _NewClientHomeScreenState();
}

class _NewClientHomeScreenState extends ConsumerState<NewClientHomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Загружаем специалистов при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(specialistsProvider.notifier).loadSpecialists();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firestoreAuthProvider);
    final userName = authState.user?.name ?? 'Пользователь';
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Greeting and Notifications
              _buildHeader(context, userName),
              
              const SizedBox(height: AppConstants.spacingLG),
              
              // Search Bar
              _buildSearchBar(),
              
              const SizedBox(height: AppConstants.spacingLG),
              
              // Carousel Banner
              _buildBannerCarousel(),
              
              const SizedBox(height: AppConstants.spacingLG),
              
              // Categories Section
              _buildCategoriesSection(),
              
              const SizedBox(height: AppConstants.spacingLG),
              
              // Top Specialists Section
              _buildTopSpecialistsSection(),
              
              const SizedBox(height: AppConstants.spacingLG),
              
              // Recommended Specialists Section
              _buildRecommendedSpecialistsSection(),
              
              const SizedBox(height: AppConstants.spacingLG),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLG + 4),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Привет, $userName! 👋',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Найдите лучших специалистов рядом с вами',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(AppConstants.radiusLG),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        context.go('/home/search');
      },
      child: DesignSystemSearchBar(
        hintText: 'Поиск специалистов, услуг...',
        onChanged: (value) {
          // Здесь будет логика поиска
        },
        onSubmitted: (value) {
          // Здесь будет логика поиска
        },
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Специальные предложения',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        BannerCarousel(
          banners: _getBannerItems(),
          height: 180,
        ),
      ],
    );
  }

  List<BannerItem> _getBannerItems() {
    return [
      BannerItem(
        title: 'Скидка 20% новым клиентам',
        subtitle: 'Получите скидку на первый заказ',
        buttonText: 'Узнать больше',
        gradient: const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.local_offer,
        onTap: () {
          // TODO: Navigate to promotion details
        },
      ),
      BannerItem(
        title: 'Бесплатная консультация',
        subtitle: 'Получите профессиональный совет',
        buttonText: 'Получить',
        gradient: const LinearGradient(
          colors: [Color(0xFF84CC16), Color(0xFF65A30D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.chat_bubble_outline,
        onTap: () {
          // TODO: Navigate to consultation
        },
      ),
      BannerItem(
        title: 'Рефералка: Приведи друга',
        subtitle: 'Получите бонус за каждого друга',
        buttonText: 'Пригласить',
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.group_add,
        onTap: () {
          // TODO: Navigate to referral program
        },
      ),
    ];
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Категории услуг',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go('/home/categories');
              },
              child: Text(
                'Все',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.serviceCategories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.serviceCategories[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: AppConstants.spacingMD),
                child: CategoryCard(
                  id: category['id']!,
                  name: category['name']!,
                  icon: category['icon']!,
                  color: category['color']!,
                  emoji: category['emoji']!,
                  onTap: () {
                    context.go('/home/categories');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopSpecialistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⭐ ТОП недели',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Самые популярные мастера',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all specialists
              },
              child: const Text('Все'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Consumer(
          builder: (context, ref, child) {
            final specialistsState = ref.watch(specialistsProvider);
            
            if (specialistsState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (specialistsState.error != null) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки специалистов',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }
            
            if (specialistsState.specialists.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_search,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Специалисты не найдены',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }
            
            // Берем топ 3 специалистов с лучшим рейтингом
            final topSpecialists = specialistsState.specialists
                .where((s) => s.rating != null && s.rating! > 4.5)
                .take(3)
                .toList();
            
            if (topSpecialists.isEmpty) {
              // Если нет топ специалистов, берем первых 3
              final fallbackSpecialists = specialistsState.specialists.take(3).toList();
              return SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: fallbackSpecialists.length,
                  itemBuilder: (context, index) {
                    final specialist = fallbackSpecialists[index];
                    return TopSpecialistCard(
                      specialist: specialist,
                      onTap: () {
                        context.go('/home/specialist/${specialist.id}');
                      },
                      onBook: () {
                        context.go('/home/booking/service-selection/${specialist.id}');
                      },
                      onChat: () {
                        // TODO: Navigate to chat
                      },
                    );
                  },
                ),
              );
            }
            
            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topSpecialists.length,
                itemBuilder: (context, index) {
                  final specialist = topSpecialists[index];
                  return TopSpecialistCard(
                    specialist: specialist,
                    onTap: () {
                      context.go('/home/specialist/${specialist.id}');
                    },
                    onBook: () {
                      context.go('/home/order-create/${specialist.id}');
                    },
                    onChat: () {
                      // TODO: Navigate to chat
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendedSpecialistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              child: Text(
                'Все',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Consumer(
          builder: (context, ref, child) {
            final specialistsState = ref.watch(specialistsProvider);
            
            if (specialistsState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (specialistsState.error != null) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки специалистов',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }
            
            if (specialistsState.specialists.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_search,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Специалисты не найдены',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }
            
            // Берем рекомендованных специалистов (пропускаем топ 3)
            final recommendedSpecialists = specialistsState.specialists.skip(3).take(5).toList();
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendedSpecialists.length,
              itemBuilder: (context, index) {
                final specialist = recommendedSpecialists[index];
                final lat = specialist.location?['lat']?.toDouble() ?? 0.0;
                final lng = specialist.location?['lng']?.toDouble() ?? 0.0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingMD),
                  child: SpecialistCard(
                    name: specialist.name ?? 'Специалист',
                    category: specialist.category ?? 'Специалист',
                    location: '$lat, $lng',
                    rating: specialist.rating ?? 0.0,
                    reviewCount: specialist.totalOrders ?? 0,
                    avatarUrl: specialist.avatarUrl,
                    isFeatured: specialist.isVerified ?? false,
                    onTap: () {
                      context.go('/home/specialist/${specialist.id}');
                    },
                    onBook: () {
                      context.go('/home/booking/service-selection/${specialist.id}');
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

