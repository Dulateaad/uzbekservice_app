import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ios_liquid_button.dart';

class BeautifulHomeScreen extends ConsumerWidget {
  const BeautifulHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Приветствие
              Text(
                'Привет, ${authState.user?.name ?? 'Пользователь'}! 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Что вам нужно сегодня?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Поиск
              Card(
                elevation: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск специалистов...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Категории
              const Text(
                'Категории услуг',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildCategoryCard(
                    context: context,
                    icon: Icons.content_cut,
                    title: 'Парикмахер',
                    color: AppConstants.primaryColor,
                    onTap: () => context.go('/home/categories'),
                  ),
                  _buildCategoryCard(
                    context: context,
                    icon: Icons.child_care,
                    title: 'Няня',
                    color: AppConstants.secondaryColor,
                    onTap: () => context.go('/home/categories'),
                  ),
                  _buildCategoryCard(
                    context: context,
                    icon: Icons.build,
                    title: 'Домашний мастер',
                    color: Colors.orange,
                    onTap: () => context.go('/home/categories'),
                  ),
                  _buildCategoryCard(
                    context: context,
                    icon: Icons.construction,
                    title: 'Строительство',
                    color: Colors.green,
                    onTap: () => context.go('/home/categories'),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Быстрые действия
              const Text(
                'Быстрые действия',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: IOSLiquidButton(
                      text: 'Найти специалиста',
                      icon: Icons.search,
                      onPressed: () => context.go('/home/categories'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: IOSLiquidButton(
                      text: 'Мои заказы',
                      icon: Icons.shopping_bag,
                      onPressed: () {
                        // Переключаемся на вкладку заказов
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Последние заказы
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Последние заказы',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'У вас пока нет заказов',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 100), // Отступ для навигации
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}