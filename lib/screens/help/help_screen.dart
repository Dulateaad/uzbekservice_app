import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<FAQItem> _faqItems = [
    FAQItem(
      id: '1',
      category: 'general',
      question: 'Как создать заказ?',
      answer: 'Для создания заказа:\n1. Нажмите кнопку "Создать заказ"\n2. Выберите категорию услуги\n3. Выберите специалиста\n4. Укажите детали заказа\n5. Выберите дату и время\n6. Подтвердите заказ',
      isExpanded: false,
    ),
    FAQItem(
      id: '2',
      category: 'general',
      question: 'Как связаться со специалистом?',
      answer: 'Вы можете связаться со специалистом через:\n• Чат в приложении\n• Звонок по телефону\n• Личную встречу',
      isExpanded: false,
    ),
    FAQItem(
      id: '3',
      category: 'payment',
      question: 'Как оплатить заказ?',
      answer: 'Оплата заказа возможна:\n• Наличными при встрече\n• Через карту в приложении\n• Банковским переводом\n• Электронными кошельками',
      isExpanded: false,
    ),
    FAQItem(
      id: '4',
      category: 'payment',
      question: 'Можно ли отменить заказ?',
      answer: 'Да, вы можете отменить заказ:\n• До начала выполнения - бесплатно\n• После начала - по договоренности со специалистом\n• В случае форс-мажора - полный возврат',
      isExpanded: false,
    ),
    FAQItem(
      id: '5',
      category: 'account',
      question: 'Как изменить профиль?',
      answer: 'Для изменения профиля:\n1. Перейдите в раздел "Профиль"\n2. Нажмите "Редактировать"\n3. Внесите изменения\n4. Сохраните изменения',
      isExpanded: false,
    ),
    FAQItem(
      id: '6',
      category: 'account',
      question: 'Как удалить аккаунт?',
      answer: 'Для удаления аккаунта:\n1. Перейдите в "Настройки"\n2. Выберите "Удалить аккаунт"\n3. Подтвердите действие\nВнимание: это действие необратимо!',
      isExpanded: false,
    ),
    FAQItem(
      id: '7',
      category: 'technical',
      question: 'Приложение не работает, что делать?',
      answer: 'Попробуйте:\n1. Перезапустить приложение\n2. Проверить интернет-соединение\n3. Обновить приложение\n4. Очистить кэш\n5. Обратиться в поддержку',
      isExpanded: false,
    ),
    FAQItem(
      id: '8',
      category: 'technical',
      question: 'Как обновить приложение?',
      answer: 'Обновление приложения:\n• iOS: App Store → Обновления\n• Android: Google Play → Мои приложения\n• Автообновления можно включить в настройках',
      isExpanded: false,
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
            child: _buildContent(),
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
        'Помощь и поддержка',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.contact_support, color: AppConstants.primaryColor),
          onPressed: _showContactSupport,
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
          hintText: 'Поиск по вопросам...',
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
      {'key': 'general', 'label': 'Общие', 'icon': Icons.help_outline},
      {'key': 'payment', 'label': 'Оплата', 'icon': Icons.payment},
      {'key': 'account', 'label': 'Аккаунт', 'icon': Icons.person},
      {'key': 'technical', 'label': 'Технические', 'icon': Icons.build},
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

  Widget _buildContent() {
    final filteredItems = _getFilteredItems();
    
    if (filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingMD),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            return _buildFAQItem(filteredItems[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item, int index) {
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
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: Text(
                    item.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  leading: Icon(
                    _getCategoryIcon(item.category),
                    color: AppConstants.primaryColor,
                    size: 20,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        item.answer,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
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
            Icons.search_off,
            size: 80,
            color: AppConstants.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.spacingLG),
          Text(
            'Ничего не найдено',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Text(
            'Попробуйте изменить поисковый запрос\nили выберите другую категорию',
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

  List<FAQItem> _getFilteredItems() {
    List<FAQItem> filtered = List.from(_faqItems);
    
    // Фильтр по категории
    if (_selectedCategory != 'all') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }
    
    // Фильтр по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) =>
          item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.answer.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'general':
        return Icons.help_outline;
      case 'payment':
        return Icons.payment;
      case 'account':
        return Icons.person;
      case 'technical':
        return Icons.build;
      default:
        return Icons.help;
    }
  }

  void _showContactSupport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactSupportSheet(),
    );
  }
}

class FAQItem {
  final String id;
  final String category;
  final String question;
  final String answer;
  final bool isExpanded;

  FAQItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.isExpanded,
  });
}

class _ContactSupportSheet extends StatefulWidget {
  @override
  State<_ContactSupportSheet> createState() => _ContactSupportSheetState();
}

class _ContactSupportSheetState extends State<_ContactSupportSheet> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedTopic = 'general';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppConstants.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.contact_support,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Связаться с поддержкой',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Форма
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Тема обращения
                  Text(
                    'Тема обращения',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                      border: Border.all(color: AppConstants.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTopic,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'general', child: Text('Общие вопросы')),
                          DropdownMenuItem(value: 'technical', child: Text('Технические проблемы')),
                          DropdownMenuItem(value: 'payment', child: Text('Проблемы с оплатой')),
                          DropdownMenuItem(value: 'account', child: Text('Проблемы с аккаунтом')),
                          DropdownMenuItem(value: 'other', child: Text('Другое')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTopic = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Email
                  Text(
                    'Email для ответа',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'your@email.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        borderSide: BorderSide(color: AppConstants.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        borderSide: BorderSide(color: AppConstants.primaryColor),
                      ),
                      filled: true,
                      fillColor: AppConstants.backgroundColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Сообщение
                  Text(
                    'Сообщение',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Опишите вашу проблему подробно...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        borderSide: BorderSide(color: AppConstants.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        borderSide: BorderSide(color: AppConstants.primaryColor),
                      ),
                      filled: true,
                      fillColor: AppConstants.backgroundColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Контактная информация
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                      border: Border.all(
                        color: AppConstants.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppConstants.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Контактная информация',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: support@odo.uz\nТелефон: +998 90 123 45 67\nTelegram: @odo_support',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Кнопки
                  Row(
                    children: [
                      Expanded(
                        child:                         DesignSystemButton(
                          text: 'Отмена',
                          onPressed: () => Navigator.pop(context),
                          type: ButtonType.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DesignSystemButton(
                          text: 'Отправить',
                          onPressed: _submitSupportRequest,
                          isLoading: _isSubmitting,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitSupportRequest() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, опишите вашу проблему'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Имитация отправки запроса
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Запрос отправлен! Мы свяжемся с вами в ближайшее время.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
