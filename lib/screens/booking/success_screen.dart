import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/firestore_models.dart';
import '../../widgets/design_system_button.dart';

class BookingSuccessScreen extends ConsumerWidget {
  final String specialistId;
  final FirestoreOrder order;

  const BookingSuccessScreen({
    super.key,
    required this.specialistId,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = order.services;
    final date = order.scheduledDate;
    final time = order.timeSlot ?? '';
    final address = order.address ?? '';
    final totalPrice = order.price.toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),
              Text(
                'Заказ успешно создан!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingMD),
              Text(
                'Ваш заказ принят. Специалист свяжется с вами в ближайшее время.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppConstants.textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXL),
              _buildOrderDetailsCard(context, services, date, time, address, totalPrice),
              const SizedBox(height: AppConstants.spacingXL),
              Column(
                children: [
                  DesignSystemButton(
                    text: 'Перейти к заказам',
                    onPressed: () => context.go('/home/orders'),
                    type: ButtonType.primary,
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  DesignSystemButton(
                    text: 'На главную',
                    onPressed: () => context.go('/home'),
                    type: ButtonType.secondary,
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard(
    BuildContext context,
    List<OrderServiceItem> services,
    DateTime date,
    String time,
    String address,
    String totalPrice,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppConstants.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Детали заказа',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          _buildDetailRow(
            context,
            label: 'Номер заказа:',
            value: _formatOrderNumber(order.id),
          ),
          const SizedBox(height: AppConstants.spacingSM),
          _buildDetailRow(
            context,
            label: 'Дата и время:',
            value: '${_formatDate(date)}${time.isNotEmpty ? ' в $time' : ''}',
          ),
          const SizedBox(height: AppConstants.spacingSM),
          _buildDetailRow(
            context,
            label: 'Адрес:',
            value: address,
            multiline: true,
          ),
          const SizedBox(height: AppConstants.spacingSM),
          _buildDetailRow(
            context,
            label: 'Сумма:',
            value: '$totalPrice сум',
            valueStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryColor,
                ),
          ),
          if (services.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingLG),
            Text(
              'Услуги:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
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
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    TextStyle? valueStyle,
    bool multiline = false,
  }) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppConstants.textSecondary,
        );
    final valueTextStyle = valueStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return Row(
      crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSM),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: valueTextStyle,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatOrderNumber(String id) {
    if (id.isEmpty) return '#—';
    final suffixLength = id.length > 6 ? 6 : id.length;
    final suffix = id.substring(id.length - suffixLength);
    return '#$suffix';
  }
}
