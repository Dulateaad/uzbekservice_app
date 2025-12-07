import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../widgets/design_system_button.dart';
import '../../services/analytics_service.dart';

class PaymentSuccessScreen extends ConsumerWidget {
  final String orderId;
  final String paymentMethod;
  final double? amount;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    required this.paymentMethod,
    this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Логируем успешную оплату при открытии экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (amount != null) {
        AnalyticsService.logPaymentCompleted(
          orderId: orderId,
          paymentMethod: paymentMethod,
          amount: amount!,
        );
      }
    });
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            children: [
              const Spacer(),
              
              // Success Animation
              _buildSuccessIcon(),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                paymentMethod == 'cash' 
                    ? 'Заказ подтверждён!' 
                    : 'Оплата успешна!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                paymentMethod == 'cash'
                    ? 'Не забудьте подготовить ${amount != null ? "${_formatPrice(amount!)} сум" : "сумму"} наличными'
                    : 'Деньги успешно списаны с вашей карты',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Order Info Card
              _buildOrderInfoCard(context),
              
              const SizedBox(height: 24),
              
              // Payment Details
              if (amount != null) _buildPaymentDetails(context),
              
              const Spacer(),
              
              // Buttons
              DesignSystemButton(
                text: 'Перейти к заказу',
                onPressed: () {
                  context.go('/orders/$orderId');
                },
                type: ButtonType.primary,
              ),
              
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'На главную',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.successColor,
                  AppConstants.successColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppConstants.successColor.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppConstants.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Номер заказа',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${orderId.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: paymentMethod == 'cash'
                      ? AppConstants.warningColor.withOpacity(0.1)
                      : AppConstants.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  paymentMethod == 'cash' ? 'Наличные' : 'Оплачено',
                  style: TextStyle(
                    color: paymentMethod == 'cash'
                        ? AppConstants.warningColor
                        : AppConstants.successColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMD),
          const Divider(),
          const SizedBox(height: AppConstants.spacingMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                context,
                icon: Icons.calendar_today,
                label: 'Дата',
                value: _formatDate(DateTime.now()),
              ),
              _buildInfoItem(
                context,
                icon: Icons.access_time,
                label: 'Время',
                value: _formatTime(DateTime.now()),
              ),
              _buildInfoItem(
                context,
                icon: Icons.payment,
                label: 'Способ',
                value: _getPaymentMethodName(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppConstants.textSecondary,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            '${_formatPrice(amount!)} сум',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName() {
    switch (paymentMethod) {
      case 'click':
        return 'Click';
      case 'payme':
        return 'Payme';
      case 'cash':
        return 'Наличные';
      default:
        return 'Карта';
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

