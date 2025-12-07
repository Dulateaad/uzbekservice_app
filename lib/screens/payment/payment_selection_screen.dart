import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/payment_model.dart';
import '../../widgets/design_system_button.dart';
import '../../services/analytics_service.dart';

class PaymentSelectionScreen extends ConsumerStatefulWidget {
  final String orderId;
  final double amount;
  final String specialistName;

  const PaymentSelectionScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.specialistName,
  });

  @override
  ConsumerState<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends ConsumerState<PaymentSelectionScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.click;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Способ оплаты'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildOrderSummary(),
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Payment Methods
                  Text(
                    'Выберите способ оплаты',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  
                  // Click
                  _buildPaymentMethodCard(
                    method: PaymentMethod.click,
                    title: 'Click',
                    subtitle: 'Uzcard, Humo, Visa, Mastercard',
                    icon: _buildClickLogo(),
                    isPopular: true,
                  ),
                  
                  const SizedBox(height: AppConstants.spacingSM),
                  
                  // Payme
                  _buildPaymentMethodCard(
                    method: PaymentMethod.payme,
                    title: 'Payme',
                    subtitle: 'Uzcard, Humo, Visa, Mastercard',
                    icon: _buildPaymeLogo(),
                    isPopular: false,
                  ),
                  
                  const SizedBox(height: AppConstants.spacingSM),
                  
                  // Cash
                  _buildPaymentMethodCard(
                    method: PaymentMethod.cash,
                    title: 'Наличными',
                    subtitle: 'Оплата при получении услуги',
                    icon: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppConstants.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        color: AppConstants.successColor,
                        size: 24,
                      ),
                    ),
                    isPopular: false,
                  ),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Security Info
                  _buildSecurityInfo(),
                ],
              ),
            ),
          ),
          
          // Bottom Button
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingLG),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusXL),
                topRight: Radius.circular(AppConstants.radiusXL),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'К оплате:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${_formatPrice(widget.amount)} сум',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMD),
                  DesignSystemButton(
                    text: _getButtonText(),
                    onPressed: _processPayment,
                    type: ButtonType.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppConstants.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                      'Заказ #${widget.orderId.substring(0, 8).toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.specialistName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required Widget icon,
    bool isPopular = false,
  }) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppConstants.spacingMD),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppConstants.primaryColor.withOpacity(0.05)
              : AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(
            color: isSelected 
                ? AppConstants.primaryColor 
                : AppConstants.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.successColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Популярный',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMethod = value);
                }
              },
              activeColor: AppConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B4E6), Color(0xFF0099CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'C',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymeLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00CCCC), Color(0xFF00B3B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'P',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.infoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: AppConstants.infoColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.infoColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.security,
              color: AppConstants.infoColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Безопасная оплата',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.infoColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Все платежи защищены SSL-шифрованием. Мы не храним данные вашей карты.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (_selectedMethod) {
      case PaymentMethod.click:
        return 'Оплатить через Click';
      case PaymentMethod.payme:
        return 'Оплатить через Payme';
      case PaymentMethod.cash:
        return 'Подтвердить (наличные)';
      default:
        return 'Оплатить';
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  void _processPayment() {
    // Логируем начало оплаты
    final paymentMethod = _selectedMethod == PaymentMethod.click 
        ? 'click' 
        : _selectedMethod == PaymentMethod.payme 
            ? 'payme' 
            : 'cash';
    
    AnalyticsService.logPaymentStarted(
      orderId: widget.orderId,
      paymentMethod: paymentMethod,
      amount: widget.amount,
    );
    
    switch (_selectedMethod) {
      case PaymentMethod.click:
        context.push(
          '/payment/click',
          extra: {
            'orderId': widget.orderId,
            'amount': widget.amount,
            'specialistName': widget.specialistName,
          },
        );
        break;
      case PaymentMethod.payme:
        // TODO: Интеграция с Payme
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payme скоро будет доступен'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      case PaymentMethod.cash:
        _confirmCashPayment();
        break;
      default:
        break;
    }
  }

  void _confirmCashPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        title: const Row(
          children: [
            Icon(Icons.payments, color: AppConstants.successColor),
            SizedBox(width: 12),
            Text('Оплата наличными'),
          ],
        ),
        content: Text(
          'Вы оплатите ${_formatPrice(widget.amount)} сум наличными при получении услуги.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/payment/success', extra: {
                'orderId': widget.orderId,
                'paymentMethod': 'cash',
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
            ),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }
}

