import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/firestore_models.dart';
import '../../providers/booking_provider.dart';
import '../../providers/firestore_auth_provider.dart';
import '../../widgets/design_system_button.dart';

class ConfirmationScreen extends ConsumerWidget {
  final String specialistId;

  const ConfirmationScreen({
    super.key,
    required this.specialistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider(specialistId));
    final bookingNotifier = ref.read(bookingProvider(specialistId).notifier);
    final authState = ref.watch(firestoreAuthProvider);

    final specialist = bookingState.specialist;
    final services = bookingState.selectedServices;
    final totalPrice = bookingState.totalPrice;
    final totalDuration = bookingState.totalDurationMinutes;
    final date = bookingState.selectedDate;
    final time = bookingState.selectedTimeSlot;
    final address = bookingState.addressLine;
    final comment = bookingState.additionalNote;

    final canConfirm = services.isNotEmpty && date != null && time != null && address.isNotEmpty;
    
    // Собираем список того, что не заполнено
    final List<String> missingItems = [];
    if (services.isEmpty) missingItems.add('услуги');
    if (date == null) missingItems.add('дата');
    if (time == null) missingItems.add('время');
    if (address.isEmpty) missingItems.add('адрес');

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Подтверждение'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Row(
              children: const [
                _Breadcrumb(text: 'Шаг 4 из 4', isActive: true),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSpecialistInfo(context, specialist),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildSelectedServices(context, services),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildDateTime(context, date, time),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildAddress(context, address, comment),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildTotalPrice(context, totalPrice, totalDuration),
                ],
              ),
            ),
          ),
          Container(
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
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Показываем что не заполнено
                  if (!canConfirm && missingItems.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppConstants.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppConstants.warningColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppConstants.warningColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Не заполнено: ${missingItems.join(", ")}',
                              style: TextStyle(
                                color: AppConstants.warningColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  DesignSystemButton(
                    text: bookingState.isSubmitting 
                        ? 'Создание заказа...' 
                        : (canConfirm ? 'Подтвердить заказ' : 'Заполните все поля'),
                    onPressed: bookingState.isSubmitting
                        ? null
                        : () {
                            if (!canConfirm) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Заполните: ${missingItems.join(", ")}'),
                                  backgroundColor: AppConstants.warningColor,
                                ),
                              );
                              return;
                            }
                            _confirmBooking(
                              context: context,
                              ref: ref,
                              bookingNotifier: bookingNotifier,
                              authState: authState,
                            );
                          },
                    type: canConfirm ? ButtonType.primary : ButtonType.secondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking({
    required BuildContext context,
    required WidgetRef ref,
    required BookingNotifier bookingNotifier,
    required FirestoreAuthState authState,
  }) async {
    final currentUser = authState.user;
    final bookingState = ref.read(bookingProvider(specialistId));

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось определить пользователя. Авторизуйтесь заново.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final savedOrder = await bookingNotifier.createOrder(
        clientId: currentUser.id,
        customAddress: bookingState.addressLine,
        location: bookingState.location,
      );

      if (savedOrder != null && context.mounted) {
        // Переходим на экран выбора оплаты
        context.push('/payment/select', extra: {
          'orderId': savedOrder.id,
          'amount': bookingState.totalPrice,
          'specialistName': bookingState.specialist?.name ?? 'Специалист',
        });
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorDialog(context, e.toString(), bookingState);
    }
  }

  void _showErrorDialog(BuildContext context, String error, BookingState bookingState) {
    final errorDetails = '''
🚨 ОШИБКА СОЗДАНИЯ ЗАКАЗА

❌ Ошибка: $error

📋 Детали заказа:
- Специалист: ${bookingState.specialist?.name ?? 'Не выбран'}
- Услуги: ${bookingState.selectedServices.map((s) => s.name).join(', ')}
- Дата: ${bookingState.selectedDate}
- Время: ${bookingState.selectedTimeSlot}
- Адрес: ${bookingState.addressLine}
- Сумма: ${bookingState.totalPrice} сум

📱 Время: ${DateTime.now()}
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
            const SizedBox(width: 12),
            const Text('Ошибка'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: SelectableText(
                error,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Нажмите "Копировать" чтобы скопировать полную информацию об ошибке',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: errorDetails));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Ошибка скопирована!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Копировать'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistInfo(BuildContext context, FirestoreUser? specialist) {
    final name = specialist?.name ?? 'Специалист';
    final category = specialist?.category ?? 'Категория не указана';
    final rating = specialist?.rating ?? 0;
    final orders = specialist?.totalOrders ?? 0;

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
          CircleAvatar(
            radius: 30,
            backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating > 0 ? rating.toStringAsFixed(1) : '—',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      orders > 0 ? '($orders заказов)' : '',
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
    );
  }

  Widget _buildSelectedServices(BuildContext context, List<FirestoreSpecialistService> services) {
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
            'Выбранные услуги',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          ...services.map(
            (service) => Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
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
                          service.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if ((service.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            service.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppConstants.textSecondary,
                                ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${service.durationMinutes} мин',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppConstants.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${service.price.toStringAsFixed(0)} сум',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTime(BuildContext context, DateTime? date, String? time) {
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
            'Дата и время',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingSM),
              Text(
                date != null ? _formatDate(date) : 'Дата не выбрана',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSM),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingSM),
              Text(
                time ?? 'Время не выбрано',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(BuildContext context, String address, String? comment) {
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
            'Адрес',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (comment != null && comment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        comment,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPrice(BuildContext context, double totalPrice, int totalDuration) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Время выполнения:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '$totalDuration мин',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Итого к оплате:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)} сум',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _Breadcrumb extends StatelessWidget {
  final String text;
  final bool isActive;

  const _Breadcrumb({
    required this.text,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSM,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppConstants.primaryColor : AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
        border: Border.all(
          color: isActive ? AppConstants.primaryColor : AppConstants.borderColor,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AppConstants.primaryContrastColor : AppConstants.textSecondary,
        ),
      ),
    );
  }
}
