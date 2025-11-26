import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'Uzcard',
      'lastFour': '1234',
      'holder': 'Валиева Н.',
      'isPrimary': true,
      'expires': '12/26',
    },
    {
      'type': 'Humo',
      'lastFour': '5678',
      'holder': 'Валиева Н.',
      'isPrimary': false,
      'expires': '04/25',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        title: const Text('Способы оплаты'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Привяжите карту, чтобы оплачивать услуги и получать бонусы за каждую оплату.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _paymentMethods.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      itemCount: _paymentMethods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final method = _paymentMethods[index];
                        return _buildPaymentCard(context, method);
                      },
                    ),
            ),
            CustomButton(
              text: 'Добавить карту',
              onPressed: () => _showAddCardSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Map<String, dynamic> method) {
    final bool isPrimary = method['isPrimary'] as bool;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        gradient: LinearGradient(
          colors: isPrimary
              ? [
                  AppConstants.primaryColor,
                  AppConstants.primaryColor.withOpacity(0.85),
                ]
              : [
                  AppConstants.surfaceColor,
                  AppConstants.surfaceColor,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          if (isPrimary)
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
        border: Border.all(
          color: isPrimary ? Colors.transparent : AppConstants.borderColor.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isPrimary
                          ? Colors.white.withOpacity(0.2)
                          : AppConstants.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: isPrimary ? Colors.white : AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['type'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isPrimary ? Colors.white : AppConstants.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '•••• ${method['lastFour']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isPrimary ? Colors.white.withOpacity(0.9) : AppConstants.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                iconColor: isPrimary ? Colors.white : AppConstants.textSecondary,
                onSelected: (value) {
                  // TODO: обработать действия с картой
                },
                itemBuilder: (context) => [
                  if (!isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Text('Сделать основной'),
                    ),
                  const PopupMenuItem(
                    value: 'rename',
                    child: Text('Переименовать'),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Удалить'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            method['holder'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isPrimary ? Colors.white : AppConstants.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Срок действия',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPrimary ? Colors.white.withOpacity(0.8) : AppConstants.textSecondary,
                    ),
              ),
              Text(
                method['expires'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isPrimary ? Colors.white : AppConstants.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          if (isPrimary) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Основной способ оплаты',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 56,
              color: AppConstants.primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Добавьте способ оплаты',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Привяжите карту, чтобы оплачивать услуги и получать бонусы.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondary,
                  height: 1.4,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Добавить карту',
            onPressed: () => _showAddCardSheet(context),
          ),
        ],
      ),
    );
  }

  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppConstants.borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Text(
                'Добавить карту',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Номер карты',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'ММ/ГГ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                        ),
                      ),
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                        ),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Имя держателя',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Сохранить карту',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Карта добавлена'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


