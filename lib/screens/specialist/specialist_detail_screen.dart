import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';
import '../../models/firestore_models.dart';
import '../../providers/firestore_providers.dart';
import '../../services/firestore_service.dart';
import '../../services/test_data_service.dart';

class SpecialistDetailScreen extends ConsumerStatefulWidget {
  final String specialistId;

  const SpecialistDetailScreen({
    super.key,
    required this.specialistId,
  });

  @override
  ConsumerState<SpecialistDetailScreen> createState() => _SpecialistDetailScreenState();
}

class _SpecialistDetailScreenState extends ConsumerState<SpecialistDetailScreen> {
  FirestoreUser? specialist;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSpecialist();
  }

  Future<void> _loadSpecialist() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Пытаемся загрузить из Firestore
      try {
        specialist = await FirestoreService.getUserById(widget.specialistId);
      } catch (e) {
        print('⚠️ Firestore недоступен, используем тестовые данные: $e');
        // Fallback к тестовым данным
        final testSpecialists = TestDataService.getTestSpecialists();
        specialist = testSpecialists.firstWhere(
          (s) => s.id == widget.specialistId,
          orElse: () => testSpecialists.first,
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null || specialist == null) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppConstants.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
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
                'Ошибка загрузки профиля',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error ?? 'Специалист не найден',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              DesignSystemButton(
                text: 'Назад',
                onPressed: () => context.pop(),
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero Section
          _buildHeroSection(),
          
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Основная информация
                  _buildMainInfo(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Статистика
                  _buildStatistics(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Бейджи достижений
                  _buildAchievementBadges(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Описание
                  _buildDescription(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Услуги и цены
                  _buildServices(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Галерея работ
                  _buildPortfolio(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Отзывы
                  _buildReviews(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Расположение на карте
                  _buildLocation(),
                  
                  const SizedBox(height: 100), // Отступ для нижней панели
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Нижняя панель
      bottomNavigationBar: _buildBottomPanel(),
    );
  }

  Widget _buildHeroSection() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppConstants.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Фоновое изображение (если есть)
              if (specialist?.avatarUrl != null)
                Positioned.fill(
                  child: Image.network(
                    specialist!.avatarUrl!,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.3),
                  ),
                ),
              
              // Контент
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Аватар
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: specialist?.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    specialist!.avatarUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  specialist?.name?.isNotEmpty == true 
                                      ? specialist!.name![0].toUpperCase() 
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        // Статус онлайн
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            width: 20,
                            height: 20,
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
                    
                    const SizedBox(height: 16),
                    
                    // Имя
                    Text(
                      specialist?.name ?? 'Специалист',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Профессия и опыт
                    Text(
                      _getCategoryName(specialist?.category),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Локация
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ташкент, Мирабадский район',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Рейтинг
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (specialist?.rating?.round() ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${specialist?.rating?.toStringAsFixed(1) ?? '0.0'} (${specialist?.totalOrders ?? 0} отзывов)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // TODO: Add to favorites
          },
        ),
      ],
    );
  }

  Widget _buildMainInfo() {
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
            'О специалисте',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            specialist?.description ?? 'Опытный специалист с многолетним стажем работы.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppConstants.textSecondary,
              height: 1.5,
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '${specialist?.totalOrders ?? 0}',
              'Заказов',
              Icons.work_outline,
              AppConstants.primaryColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppConstants.borderColor,
          ),
          Expanded(
            child: _buildStatItem(
              '${specialist?.rating?.toStringAsFixed(1) ?? '0.0'}⭐',
              'Рейтинг',
              Icons.star_outline,
              Colors.amber,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppConstants.borderColor,
          ),
          Expanded(
            child: _buildStatItem(
              '100%',
              'Успех',
              Icons.check_circle_outline,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadges() {
    final badges = [
      {'icon': Icons.emoji_events, 'text': 'ТОП недели', 'color': Colors.amber},
      {'icon': Icons.verified, 'text': 'Проверен', 'color': Colors.green},
      {'icon': Icons.flash_on, 'text': 'Быстрый отклик', 'color': Colors.orange},
      {'icon': Icons.workspace_premium, 'text': '5 лет на платформе', 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Достижения',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Wrap(
          spacing: AppConstants.spacingSM,
          runSpacing: AppConstants.spacingSM,
          children: badges.map((badge) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMD,
                vertical: AppConstants.spacingSM,
              ),
              decoration: BoxDecoration(
                color: (badge['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                border: Border.all(
                  color: (badge['color'] as Color).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    badge['icon'] as IconData,
                    color: badge['color'] as Color,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    badge['text'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: badge['color'] as Color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription() {
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
            'Подробное описание',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Профессиональный специалист с многолетним опытом работы. Качественно выполняю все виды работ, использую современные технологии и материалы. Всегда нахожу индивидуальный подход к каждому клиенту.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppConstants.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          TextButton(
            onPressed: () {
              // TODO: Show full description
            },
            child: const Text('Читать полностью'),
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    final services = [
      {'name': 'Мужская стрижка', 'price': '50,000', 'duration': '30 мин'},
      {'name': 'Стрижка + борода', 'price': '80,000', 'duration': '45 мин'},
      {'name': 'Детская стрижка', 'price': '40,000', 'duration': '25 мин'},
      {'name': 'Укладка', 'price': '30,000', 'duration': '20 мин'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Услуги и цены',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        ...services.map((service) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
            padding: const EdgeInsets.all(AppConstants.spacingLG),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name']!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'от ${service['price']} сум • ${service['duration']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                DesignSystemButton(
                  text: 'Выбрать',
                  onPressed: () {
                    // TODO: Select service
                  },
                  type: ButtonType.secondary,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPortfolio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Портфолио',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show all portfolio
              },
              child: const Text('Смотреть все (24)'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        SizedBox(
          height: 200,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.spacingSM,
              mainAxisSpacing: AppConstants.spacingSM,
              childAspectRatio: 1,
            ),
            itemCount: 4, // Показываем первые 4 фото
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  border: Border.all(
                    color: AppConstants.borderColor,
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: AppConstants.primaryColor,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Отзывы (${specialist?.totalOrders ?? 0})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Show all reviews
              },
              child: const Text('Все отзывы'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMD),
        
        // Общий рейтинг
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
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
              Column(
                children: [
                  Text(
                    '${specialist?.rating?.toStringAsFixed(1) ?? '0.0'}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (specialist?.rating?.round() ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(width: AppConstants.spacingLG),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.8),
                    _buildRatingBar(4, 0.15),
                    _buildRatingBar(3, 0.03),
                    _buildRatingBar(2, 0.01),
                    _buildRatingBar(1, 0.01),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Последние отзывы
        ...List.generate(3, (index) {
          return _buildReviewCard();
        }),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppConstants.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).round()}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
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
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                child: Text(
                  'И',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Иван И.',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '2 дня назад',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Отличная работа! Рекомендую всем. Качественно и быстро выполнил заказ.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: AppConstants.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Полезно (12)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Расположение',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
            border: Border.all(
              color: AppConstants.borderColor,
              width: 1,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text(
                  'Карта будет доступна в следующей версии',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        DesignSystemButton(
          text: 'Открыть в картах',
          onPressed: () {
            // TODO: Open in maps
          },
          type: ButtonType.secondary,
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXL),
          topRight: Radius.circular(AppConstants.radiusXL),
        ),
        border: Border.all(
          color: AppConstants.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Цена
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'от ${specialist?.pricePerHour?.toStringAsFixed(0) ?? '50,000'} сум',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  Text(
                    'за час работы',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: AppConstants.spacingMD),
            
            // Кнопка чата
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                border: Border.all(
                  color: AppConstants.primaryColor,
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: AppConstants.primaryColor,
                ),
                onPressed: () {
                  // TODO: Open chat
                },
              ),
            ),
            
            const SizedBox(width: AppConstants.spacingMD),
            
            // Кнопка записи
            Expanded(
              flex: 2,
              child: DesignSystemButton(
                text: 'Записаться',
                onPressed: () {
                  context.go('/home/booking/service-selection/${specialist?.id}');
                },
                type: ButtonType.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(String? category) {
    switch (category) {
      case 'barber':
        return 'Барбер • 5 лет опыта';
      case 'nanny':
        return 'Няня • 3 года опыта';
      case 'handyman':
        return 'Мастер • 7 лет опыта';
      case 'construction':
        return 'Строитель • 10 лет опыта';
      case 'medical':
        return 'Медик • 8 лет опыта';
      default:
        return 'Специалист • 5 лет опыта';
    }
  }
}