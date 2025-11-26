import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_button.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  
  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).loadOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.selectedOrder;
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: orderState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderState.error != null
              ? Center(
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
                        'Ошибка загрузки',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        orderState.error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(orderProvider.notifier)
                              .loadOrderById(widget.orderId);
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                )
              : order == null
                  ? const Center(
                      child: Text('Заказ не найден'),
                    )
                  : CustomScrollView(
                      slivers: [
                        // App Bar
                        SliverAppBar(
                          expandedHeight: 200,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppConstants.primaryColor.withOpacity(0.8),
                                    AppConstants.primaryColor,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.assignment,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      order.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Контент
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Статус заказа
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(order.status),
                                        color: _getStatusColor(order.status),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        AppConstants.orderStatuses[order.status] ?? order.status,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(order.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Описание
                                const Text(
                                  'Описание',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  order.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppConstants.textSecondary,
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Детали заказа
                                const Text(
                                  'Детали заказа',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                _DetailRow(
                                  icon: Icons.calendar_today,
                                  label: 'Дата и время',
                                  value: '${order.scheduledDate.day}.${order.scheduledDate.month}.${order.scheduledDate.year} в ${order.scheduledDate.hour.toString().padLeft(2, '0')}:${order.scheduledDate.minute.toString().padLeft(2, '0')}',
                                ),
                                
                                _DetailRow(
                                  icon: Icons.access_time,
                                  label: 'Продолжительность',
                                  value: '${order.estimatedHours} часов',
                                ),
                                
                                _DetailRow(
                                  icon: Icons.attach_money,
                                  label: 'Стоимость',
                                  value: '${order.totalPrice.toStringAsFixed(0)} сум',
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Адрес
                                const Text(
                                  'Адрес',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: AppConstants.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        order.address,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppConstants.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                if (order.clientNotes != null) ...[
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Заметки',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    order.clientNotes!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppConstants.textSecondary,
                                    ),
                                  ),
                                ],
                                
                                const SizedBox(height: 100), // Отступ для кнопок
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
      
      // Кнопки действий
      bottomNavigationBar: order != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (order.status == 'pending') ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Отменить',
                        backgroundColor: Colors.red,
                        onPressed: () {
                          _cancelOrder(order.id);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: CustomButton(
                      text: order.status == 'completed' ? 'Оценить' : 'Подробнее',
                      onPressed: () {
                        if (order.status == 'completed') {
                          // TODO: Navigate to review screen
                        } else {
                          // TODO: Show more details
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.work;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  void _cancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить заказ'),
        content: const Text('Вы уверены, что хотите отменить этот заказ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Нет'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(orderProvider.notifier).updateOrderStatus(orderId, 'cancelled');
              context.go('/home/orders');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Да, отменить'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppConstants.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
