import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/review_model.dart';
import '../../widgets/design_system_button.dart';

class ReviewsScreen extends ConsumerStatefulWidget {
  final String specialistId;
  final String specialistName;

  const ReviewsScreen({
    super.key,
    required this.specialistId,
    required this.specialistName,
  });

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedFilter = 'all';
  String _selectedSort = 'newest';

  // Тестовые данные для отзывов
  final List<Review> _reviews = [
    Review(
      id: '1',
      orderId: 'order1',
      clientId: 'client1',
      specialistId: 'specialist1',
      rating: 5,
      comment: 'Отличный специалист! Очень быстро и качественно выполнил работу. Рекомендую!',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: '2',
      orderId: 'order2',
      clientId: 'client2',
      specialistId: 'specialist1',
      rating: 4,
      comment: 'Хорошая работа, но немного задержался с выполнением. В целом доволен результатом.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Review(
      id: '3',
      orderId: 'order3',
      clientId: 'client3',
      specialistId: 'specialist1',
      rating: 5,
      comment: 'Профессионал своего дела! Очень внимательный к деталям. Буду обращаться еще.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Review(
      id: '4',
      orderId: 'order4',
      clientId: 'client4',
      specialistId: 'specialist1',
      rating: 3,
      comment: 'Работа выполнена, но есть небольшие недочеты. В целом нормально.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Review(
      id: '5',
      orderId: 'order5',
      clientId: 'client5',
      specialistId: 'specialist1',
      rating: 5,
      comment: 'Супер! Все сделано быстро и качественно. Очень доволен результатом!',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildRatingSummary(),
          _buildFilterAndSort(),
          Expanded(
            child: _buildReviewsList(),
          ),
        ],
      ),
      floatingActionButton: _buildWriteReviewButton(),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Отзывы',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.specialistName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: AppConstants.primaryColor),
          onPressed: _showShareOptions,
        ),
      ],
    );
  }

  Widget _buildRatingSummary() {
    final averageRating = _reviews.fold(0.0, (sum, review) => sum + review.rating) / _reviews.length;
    final totalReviews = _reviews.length;
    
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacingMD),
      padding: const EdgeInsets.all(AppConstants.spacingLG),
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
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Общий рейтинг
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalReviews отзывов',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              // Распределение рейтингов
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final rating = 5 - index;
                    final count = _reviews.where((r) => r.rating == rating).length;
                    final percentage = totalReviews > 0 ? count / totalReviews : 0.0;
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: AppConstants.borderColor,
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: percentage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppConstants.primaryColor,
                                        AppConstants.primaryColor.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSort() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
      child: Row(
        children: [
          // Фильтр по рейтингу
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: AppConstants.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Все отзывы')),
                    DropdownMenuItem(value: '5', child: Text('5 звезд')),
                    DropdownMenuItem(value: '4', child: Text('4 звезды')),
                    DropdownMenuItem(value: '3', child: Text('3 звезды')),
                    DropdownMenuItem(value: '2', child: Text('2 звезды')),
                    DropdownMenuItem(value: '1', child: Text('1 звезда')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Сортировка
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: Border.all(color: AppConstants.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Новые')),
                  DropdownMenuItem(value: 'oldest', child: Text('Старые')),
                  DropdownMenuItem(value: 'highest', child: Text('Высокий рейтинг')),
                  DropdownMenuItem(value: 'lowest', child: Text('Низкий рейтинг')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    final filteredReviews = _getFilteredReviews();
    
    if (filteredReviews.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: filteredReviews.length,
          itemBuilder: (context, index) {
            return _buildReviewCard(filteredReviews[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review, int index) {
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
              padding: const EdgeInsets.all(AppConstants.spacingMD),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок отзыва
                  Row(
                    children: [
                      // Аватар клиента
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                        child: Text(
                          'К${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Информация о клиенте
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Клиент ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                            Text(
                              _formatDate(review.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Рейтинг
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Комментарий
                  Text(
                    review.comment,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConstants.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Дополнительная информация
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 16,
                        color: AppConstants.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Заказ #${review.orderId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (review.updatedAt != review.createdAt)
                        Text(
                          'Изменен',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                            fontStyle: FontStyle.italic,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.reviews_outlined,
            size: 80,
            color: AppConstants.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'Нет отзывов',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Пока нет отзывов для этого специалиста',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppConstants.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewButton() {
    return FloatingActionButton.extended(
      onPressed: _showWriteReviewDialog,
      backgroundColor: AppConstants.primaryColor,
      icon: const Icon(Icons.edit, color: Colors.white),
      label: const Text(
        'Написать отзыв',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  List<Review> _getFilteredReviews() {
    List<Review> filtered = List.from(_reviews);
    
    // Фильтр по рейтингу
    if (_selectedFilter != 'all') {
      final rating = int.parse(_selectedFilter);
      filtered = filtered.where((review) => review.rating == rating).toList();
    }
    
    // Сортировка
    switch (_selectedSort) {
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        filtered.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    
    return filtered;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дней назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  void _showWriteReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => _WriteReviewDialog(
        specialistId: widget.specialistId,
        specialistName: widget.specialistName,
        onReviewSubmitted: (review) {
          setState(() {
            _reviews.insert(0, review);
          });
        },
      ),
    );
  }

  void _showShareOptions() {
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
                'Поделиться отзывами',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    icon: Icons.copy,
                    label: 'Копировать',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ссылка скопирована в буфер обмена'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.message,
                    label: 'Сообщение',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildShareOption(
                    icon: Icons.more_horiz,
                    label: 'Ещё',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppConstants.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WriteReviewDialog extends StatefulWidget {
  final String specialistId;
  final String specialistName;
  final Function(Review) onReviewSubmitted;

  const _WriteReviewDialog({
    required this.specialistId,
    required this.specialistName,
    required this.onReviewSubmitted,
  });

  @override
  State<_WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<_WriteReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Icon(
                  Icons.star_outline,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Оставить отзыв',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Специалист
            Text(
              widget.specialistName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Рейтинг
            Text(
              'Оцените качество работы:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            
            // Комментарий
            Text(
              'Комментарий (необязательно):',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Расскажите о вашем опыте...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  borderSide: BorderSide(color: AppConstants.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  borderSide: BorderSide(color: AppConstants.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Кнопки
            Row(
              children: [
                Expanded(
                  child:                   DesignSystemButton(
                    text: 'Отмена',
                    onPressed: () => Navigator.pop(context),
                    type: ButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DesignSystemButton(
                    text: 'Отправить',
                    onPressed: _rating > 0 ? _submitReview : null,
                    isLoading: _isSubmitting,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitReview() async {
    if (_rating == 0) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    // Имитация отправки отзыва
    await Future.delayed(const Duration(seconds: 1));
    
    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
      clientId: 'current_client',
      specialistId: widget.specialistId,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    widget.onReviewSubmitted(review);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Отзыв успешно отправлен!'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
