import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      illustration: '🗺️',
      title: 'Найдите профессионалов рядом',
      description: 'Специалисты в вашем районе готовы помочь',
    ),
    OnboardingPage(
      illustration: '📅',
      title: 'Бронируйте в удобное время',
      description: 'Выберите дату и время, которое вам подходит',
    ),
    OnboardingPage(
      illustration: '⭐',
      title: 'Проверенные специалисты',
      description: 'Все мастера проходят верификацию',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Переход к авторизации
      context.go('/auth/phone');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Индикатор прогресса
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _pages.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryColor,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentPage + 1}/${_pages.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Контент страниц
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Кнопки навигации
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  // Кнопка "Назад" (только для страниц 2 и 3)
                  if (_currentPage > 0)
                    Expanded(
                      child:                       DesignSystemButton(
                        text: 'Назад',
                        onPressed: _previousPage,
                        type: ButtonType.ghost,
                      ),
                    ),
                  
                  if (_currentPage > 0) const SizedBox(width: 16),
                  
                  // Кнопка "Далее" / "Начать"
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child:                     DesignSystemButton(
                      text: _currentPage == _pages.length - 1 ? 'Начать' : 'Далее',
                      onPressed: _nextPage,
                      type: ButtonType.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иллюстрация
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Text(
                page.illustration,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Заголовок
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Описание
          Text(
            page.description,
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
}

class OnboardingPage {
  final String illustration;
  final String title;
  final String description;

  OnboardingPage({
    required this.illustration,
    required this.title,
    required this.description,
  });
}
