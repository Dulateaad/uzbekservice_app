import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/firestore_models.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../providers/firestore_providers.dart';
import '../../widgets/design_system_button.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firestoreAuthProvider);
    final user = authState.user;

    if (user == null) {
      return const _LoginRequiredStub();
    }

    final isSpecialist = user.userType == 'specialist';
    final ordersAsync = isSpecialist
        ? ref.watch(specialistOrdersStreamProvider(user.id))
        : ref.watch(clientOrdersStreamProvider(user.id));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppConstants.backgroundColor,
          elevation: 0,
          title: const Text('Мои заказы'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: AppConstants.primaryColor,
            labelColor: AppConstants.primaryColor,
            unselectedLabelColor: AppConstants.textSecondary,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            tabs: [
              Tab(text: 'Активные'),
              Tab(text: 'История'),
              Tab(text: 'Отмененные'),
            ],
          ),
        ),
        body: ordersAsync.when(
          data: (orders) {
            final activeStatuses = {'pending', 'accepted', 'in_progress'};
            final historyStatuses = {'completed', 'reviewed'};

            final activeOrders = orders
                .where((order) => activeStatuses.contains(order.status))
                .toList()
              ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
            final historyOrders = orders
                .where((order) => historyStatuses.contains(order.status))
                .toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            final cancelledOrders = orders
                .where((order) => order.status == 'cancelled')
                .toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            return TabBarView(
              children: [
                _OrdersTab(
                  orders: activeOrders,
                  type: _OrdersTabType.active,
                  isSpecialist: isSpecialist,
                  ref: ref,
                ),
                _OrdersTab(
                  orders: historyOrders,
                  type: _OrdersTabType.history,
                  isSpecialist: isSpecialist,
                  ref: ref,
                ),
                _OrdersTab(
                  orders: cancelledOrders,
                  type: _OrdersTabType.cancelled,
                  isSpecialist: isSpecialist,
                  ref: ref,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _ErrorState(message: error.toString()),
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({
    required this.orders,
    required this.type,
    required this.isSpecialist,
    required this.ref,
  });

  final List<FirestoreOrder> orders;
  final _OrdersTabType type;
  final bool isSpecialist;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _EmptyState(type: type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(
          order: order,
          isSpecialist: isSpecialist,
          type: type,
          ref: ref,
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isSpecialist,
    required this.type,
    required this.ref,
  });

  final FirestoreOrder order;
  final bool isSpecialist;
  final _OrdersTabType type;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(order.status);
    final scheduledTime = _formatDateTime(order.scheduledDate, order.timeSlot);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppConstants.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _OrderHeader(order: order, statusInfo: statusInfo),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Column(
              children: [
                _OrderSummary(order: order),
                const SizedBox(height: AppConstants.spacingSM),
                _OrderScheduleRow(text: scheduledTime),
                const SizedBox(height: AppConstants.spacingXS),
                _OrderAddressRow(address: order.address ?? ''),
                const SizedBox(height: AppConstants.spacingMD),
                _OrderServices(services: order.services),
                if (order.status == 'cancelled' && order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingSM),
                  _CancelledReason(message: order.notes!),
                ],
                if (order.status == 'reviewed' && order.rating != null) ...[
                  const SizedBox(height: AppConstants.spacingSM),
                  _ReviewBadge(rating: order.rating!, comment: order.review),
                ],
                const SizedBox(height: AppConstants.spacingMD),
                _OrderActions(
                  order: order,
                  isSpecialist: isSpecialist,
                  type: type,
                  ref: ref,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.order,
    required this.statusInfo,
  });

  final FirestoreOrder order;
  final _StatusInfo statusInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusLG),
          topRight: Radius.circular(AppConstants.radiusLG),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Заказ ${_formatOrderId(order.id)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingSM,
              vertical: AppConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              border: Border.all(
                color: statusInfo.color.withOpacity(0.3),
                width: 1,
              ),
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
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final FirestoreOrder order;

  @override
  Widget build(BuildContext context) {
    final primaryService = order.services.isNotEmpty ? order.services.first.name : 'Услуги специалиста';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          child: Text(
            order.specialistId.isNotEmpty ? order.specialistId[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primaryService,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.totalDurationMinutes} мин • ${order.services.length} услуг',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Text(
          '${order.price.toStringAsFixed(0)} сум',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
        ),
      ],
    );
  }
}

class _OrderScheduleRow extends StatelessWidget {
  const _OrderScheduleRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today,
          size: 16,
          color: AppConstants.textSecondary,
        ),
        const SizedBox(width: AppConstants.spacingXS),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConstants.textSecondary,
              ),
        ),
      ],
    );
  }
}

class _OrderAddressRow extends StatelessWidget {
  const _OrderAddressRow({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on,
          size: 16,
          color: AppConstants.textSecondary,
        ),
        const SizedBox(width: AppConstants.spacingXS),
        Expanded(
          child: Text(
            address,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _OrderServices extends StatelessWidget {
  const _OrderServices({required this.services});

  final List<OrderServiceItem> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Состав заказа',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textSecondary,
                ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingXS),
        ...services.map(
          (service) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacingXS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  '${service.price.toStringAsFixed(0)} сум',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelledReason extends StatelessWidget {
  const _CancelledReason({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingSM),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.red),
          const SizedBox(width: AppConstants.spacingXS),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewBadge extends StatelessWidget {
  const _ReviewBadge({required this.rating, this.comment});

  final double rating;
  final String? comment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ваша оценка: ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
            ),
            ...List.generate(5, (index) {
              final isFilled = index < rating.round();
              return Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              );
            }),
          ],
        ),
        if (comment != null && comment!.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spacingXS),
          Text(
            comment!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({
    required this.order,
    required this.isSpecialist,
    required this.type,
    required this.ref,
  });

  final FirestoreOrder order;
  final bool isSpecialist;
  final _OrdersTabType type;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    final ordersNotifier = ref.read(ordersProvider.notifier);

    if (type == _OrdersTabType.active) {
      if (isSpecialist) {
        if (order.status == 'pending') {
          actions.addAll([
            Expanded(
              child: DesignSystemButton(
                text: 'Принять заказ',
                onPressed: () => _acceptOrder(context, ordersNotifier),
                type: ButtonType.primary,
              ),
            ),
            const SizedBox(width: AppConstants.spacingSM),
            Expanded(
              child: DesignSystemButton(
                text: 'Отменить',
                onPressed: () => _cancelOrder(context, ordersNotifier),
                type: ButtonType.secondary,
              ),
            ),
          ]);
        } else if (order.status == 'accepted') {
          actions.add(
            Expanded(
              child: DesignSystemButton(
                text: 'Начать работу',
                onPressed: () => _startOrder(context, ordersNotifier),
                type: ButtonType.primary,
              ),
            ),
          );
        } else if (order.status == 'in_progress') {
          actions.add(
            Expanded(
              child: DesignSystemButton(
                text: 'Завершить заказ',
                onPressed: () => _completeOrder(context, ordersNotifier),
                type: ButtonType.primary,
              ),
            ),
          );
        }
      } else {
        actions.addAll([
          Expanded(
            child: DesignSystemButton(
              text: 'Отменить',
              onPressed: () => _cancelOrder(context, ordersNotifier),
              type: ButtonType.secondary,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSM),
          Expanded(
            child: DesignSystemButton(
              text: 'Перейти в чат',
              onPressed: () {
                context.go('/home/chat/${order.id}');
              },
              type: ButtonType.primary,
            ),
          ),
        ]);
      }
    } else if (type == _OrdersTabType.history && !isSpecialist && order.status == 'completed') {
      actions.add(
        DesignSystemButton(
          text: 'Оставить отзыв',
          onPressed: () => _leaveReview(context, ref),
          type: ButtonType.primary,
        ),
      );
    } else if (type == _OrdersTabType.history && isSpecialist) {
      actions.add(
        DesignSystemButton(
          text: 'Посмотреть чат',
          onPressed: () => context.go('/home/chat/${order.id}'),
          type: ButtonType.secondary,
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: actions);
  }

  Future<void> _cancelOrder(BuildContext context, OrdersNotifier notifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить заказ?'),
        content: const Text('Вы уверены, что хотите отменить этот заказ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Нет')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Да')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await notifier.updateOrderStatus(order.id, 'cancelled');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Заказ отменён'), backgroundColor: Colors.redAccent),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось отменить заказ: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  Future<void> _completeOrder(BuildContext context, OrdersNotifier notifier) async {
    try {
      await notifier.updateOrderStatus(order.id, 'completed');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ завершён'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось завершить заказ: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _acceptOrder(BuildContext context, OrdersNotifier notifier) async {
    try {
      await notifier.updateOrderStatus(order.id, 'accepted');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ принят'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось принять заказ: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _startOrder(BuildContext context, OrdersNotifier notifier) async {
    try {
      await notifier.updateOrderStatus(order.id, 'in_progress');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Работа начата'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось начать работу: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _leaveReview(BuildContext context, WidgetRef ref) async {
    final ratingAndComment = await _ReviewDialog.show(context);
    if (ratingAndComment == null) return;

    final (rating, comment) = ratingAndComment;
    try {
      await ref.read(ordersProvider.notifier).leaveReview(
            order: order,
            rating: rating,
            comment: comment,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Спасибо за отзыв!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось отправить отзыв: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();

  static Future<(int, String?)?> show(BuildContext context) {
    return showDialog<(int, String?)>(
      context: context,
      builder: (context) => const _ReviewDialog(),
    );
  }

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _rating = 5;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Оставьте отзыв'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final filled = index < _rating;
              return IconButton(
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Комментарий (необязательно)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop<(int, String?)>(context, (_rating, _controller.text.trim().isEmpty ? null : _controller.text.trim())),
          child: const Text('Отправить'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.type});

  final _OrdersTabType type;

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case _OrdersTabType.active:
        title = 'Нет активных заказов';
        subtitle = 'Создайте заказ, чтобы он появился здесь.';
        icon = Icons.shopping_bag_outlined;
        break;
      case _OrdersTabType.history:
        title = 'История пуста';
        subtitle = 'Здесь появятся завершённые заказы.';
        icon = Icons.history;
        break;
      case _OrdersTabType.cancelled:
        title = 'Нет отменённых заказов';
        subtitle = 'Отлично! Все заказы активны.';
        icon = Icons.cancel_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppConstants.textSecondary.withOpacity(0.5)),
            const SizedBox(height: AppConstants.spacingLG),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppConstants.textSecondary,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            if (type == _OrdersTabType.active)
              DesignSystemButton(
                text: 'Найти специалиста',
                onPressed: () => context.go('/home'),
                type: ButtonType.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _LoginRequiredStub extends StatelessWidget {
  const _LoginRequiredStub();

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
              'Войдите в аккаунт',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Авторизуйтесь, чтобы посмотреть свои заказы.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppConstants.textSecondary),
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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Не удалось загрузить заказы',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusInfo {
  const _StatusInfo(this.text, this.color);

  final String text;
  final Color color;
}

enum _OrdersTabType { active, history, cancelled }

_StatusInfo _statusInfo(String status) {
  switch (status) {
    case 'pending':
      return const _StatusInfo('Ожидает подтверждения', Colors.orange);
    case 'accepted':
      return const _StatusInfo('Принят', Colors.green);
    case 'in_progress':
      return const _StatusInfo('В работе', Colors.blue);
    case 'completed':
      return const _StatusInfo('Завершён', Colors.green);
    case 'reviewed':
      return const _StatusInfo('Отзыв оставлен', Colors.green);
    case 'cancelled':
      return const _StatusInfo('Отменён', Colors.redAccent);
    default:
      return const _StatusInfo('Статус неизвестен', AppConstants.textSecondary);
  }
}

String _formatDateTime(DateTime date, String? timeSlot) {
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
  final dateText = '${date.day} ${months[date.month - 1]} ${date.year}';
  return timeSlot != null && timeSlot.isNotEmpty ? '$dateText • $timeSlot' : dateText;
}

String _formatOrderId(String id) {
  if (id.isEmpty) return '№ —';
  final suffixLength = id.length > 6 ? 6 : id.length;
  return '№${id.substring(id.length - suffixLength)}';
}