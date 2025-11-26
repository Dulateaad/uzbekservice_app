import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/firestore_models.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../providers/firestore_providers.dart';
import '../../widgets/design_system_button.dart';
import '../../widgets/ios_liquid_button.dart';

class SpecialistHomeScreen extends ConsumerStatefulWidget {
  const SpecialistHomeScreen({super.key});

  @override
  ConsumerState<SpecialistHomeScreen> createState() => _SpecialistHomeScreenState();
}

class _SpecialistHomeScreenState extends ConsumerState<SpecialistHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firestoreAuthProvider);
    final specialist = authState.user;

    if (specialist == null || specialist.userType != AppConstants.userTypeSpecialist) {
      return const _SpecialistLoginRequired();
    }

    final ordersAsync = ref.watch(specialistOrdersStreamProvider(specialist.id));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Приветствие специалиста
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.secondaryColor,
                      AppConstants.secondaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Добро пожаловать, специалист!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Управляйте своими заказами и клиентами',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Статистика
              _SpecialistStats(
                ordersAsync: ordersAsync,
                specialist: specialist,
              ),

              const SizedBox(height: 24),

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
                      text: 'Обновить профиль',
                      onPressed: () {
                        // Переход к редактированию профиля
                      },
                      backgroundColor: AppConstants.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: IOSLiquidButton(
                      text: 'Добавить фото',
                      onPressed: () {
                        // Добавление фото работ
                      },
                      backgroundColor: AppConstants.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Заказы
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Мои заказы',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/home/orders');
                    },
                    child: const Text('Все заказы'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Список заказов
              _SpecialistOrdersPreview(ordersAsync: ordersAsync),

              const SizedBox(height: 24),

              // Настройки
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingItem(
                      'Режим работы',
                      'Включить/выключить прием заказов',
                      Icons.schedule,
                      () {},
                    ),
                    _buildSettingItem(
                      'Уведомления',
                      'Настройки уведомлений',
                      Icons.notifications,
                      () {},
                    ),
                    _buildSettingItem(
                      'Помощь',
                      'Связаться с поддержкой',
                      Icons.help,
                      () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConstants.secondaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _SpecialistStats extends StatelessWidget {
  const _SpecialistStats({
    required this.ordersAsync,
    required this.specialist,
  });

  final AsyncValue<List<FirestoreOrder>> ordersAsync;
  final FirestoreUser specialist;

  @override
  Widget build(BuildContext context) {
    return ordersAsync.when(
      data: (orders) {
        final activeStatuses = {'pending', 'accepted', 'in_progress'};
        final activeCount = orders.where((order) => activeStatuses.contains(order.status)).length;
        final today = DateTime.now();
        final todayOrders = orders.where((order) => _isSameDay(order.scheduledDate, today)).toList();
        final todayCount = todayOrders.length;
        final earnedToday = orders
            .where((order) =>
                order.completedAt != null && _isSameDay(order.completedAt!, today))
            .fold<double>(0, (sum, order) => sum + order.price);

        final ratingValue = specialist.rating != null
            ? specialist.rating!.toStringAsFixed(1)
            : '—';

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Активные заказы',
                    '$activeCount',
                    Icons.work,
                    AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'Рейтинг',
                    ratingValue,
                    Icons.star,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Заказов сегодня',
                    '$todayCount',
                    Icons.today,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'Заработано',
                    '${earnedToday.toStringAsFixed(0)} сум',
                    Icons.monetization_on,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => Column(
        children: [
          Row(
            children: const [
              Expanded(child: _StatsSkeletonCard()),
              SizedBox(width: 12),
              Expanded(child: _StatsSkeletonCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _StatsSkeletonCard()),
              SizedBox(width: 12),
              Expanded(child: _StatsSkeletonCard()),
            ],
          ),
        ],
      ),
      error: (error, stack) => Column(
        children: [
          _statCard('Активные заказы', '—', Icons.work, AppConstants.primaryColor),
          const SizedBox(height: 12),
          _statCard('Заказов сегодня', '—', Icons.today, Colors.green),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _StatsSkeletonCard extends StatelessWidget {
  const _StatsSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _SpecialistOrdersPreview extends StatelessWidget {
  const _SpecialistOrdersPreview({required this.ordersAsync});

  final AsyncValue<List<FirestoreOrder>> ordersAsync;

  @override
  Widget build(BuildContext context) {
    return ordersAsync.when(
      data: (orders) {
        final upcoming = orders
            .where((order) => order.status != 'cancelled')
            .toList()
          ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

        final preview = upcoming.take(3).toList();

        if (preview.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.assignment, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Нет активных заказов',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preview.length,
          itemBuilder: (context, index) {
            final order = preview[index];
            return _SpecialistOrderTile(order: order);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(
              'Ошибка загрузки заказов: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialistOrderTile extends StatelessWidget {
  const _SpecialistOrderTile({required this.order});

  final FirestoreOrder order;

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(order.status);
    final scheduledText = _formatPreviewDate(order.scheduledDate, order.timeSlot);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.services.isNotEmpty ? order.services.first.name : 'Заказ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusInfo.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusInfo.text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusInfo.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            scheduledText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${order.price.toStringAsFixed(0)} сум • ${order.totalDurationMinutes} мин',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialistLoginRequired extends StatelessWidget {
  const _SpecialistLoginRequired();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppConstants.textSecondary),
            const SizedBox(height: AppConstants.spacingLG),
            Text(
              'Требуется учетная запись специалиста',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Войдите как специалист, чтобы управлять заказами.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            DesignSystemButton(
              text: 'Войти',
              onPressed: () => context.go('/auth/phone'),
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }
}

_StatusInfo _statusInfo(String status) {
  switch (status) {
    case 'pending':
      return const _StatusInfo('Ожидает', Colors.orange);
    case 'accepted':
      return const _StatusInfo('Принят', Colors.blue);
    case 'in_progress':
      return const _StatusInfo('В работе', Colors.purple);
    case 'completed':
      return const _StatusInfo('Завершён', Colors.green);
    case 'reviewed':
      return const _StatusInfo('Отзыв', Colors.green);
    case 'cancelled':
      return const _StatusInfo('Отменён', Colors.redAccent);
    default:
      return const _StatusInfo('Неизвестно', Colors.grey);
  }
}

String _formatPreviewDate(DateTime date, String? timeSlot) {
  final months = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  final dateText = '${date.day} ${months[date.month - 1]}';
  return timeSlot != null && timeSlot.isNotEmpty ? '$dateText • $timeSlot' : dateText;
}

class _StatusInfo {
  const _StatusInfo(this.text, this.color);

  final String text;
  final Color color;
}

Widget _statCard(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
