import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/firestore_models.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/design_system_button.dart';

class ServiceSelectionScreen extends ConsumerWidget {
  final String specialistId;

  const ServiceSelectionScreen({
    super.key,
    required this.specialistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider(specialistId));
    final bookingNotifier = ref.read(bookingProvider(specialistId).notifier);

    final totalPrice = bookingState.totalPrice;
    final totalDuration = bookingState.totalDurationMinutes;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Выбор услуги'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Хлебные крошки
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Row(
              children: const [
                _Breadcrumb(text: 'Шаг 1 из 4', isActive: true),
                SizedBox(width: AppConstants.spacingSM),
                _Breadcrumb(text: 'Дата и время'),
                SizedBox(width: AppConstants.spacingSM),
                _Breadcrumb(text: 'Адрес'),
                SizedBox(width: AppConstants.spacingSM),
                _Breadcrumb(text: 'Подтверждение'),
              ],
            ),
          ),

          // Список услуг
          Expanded(
            child: bookingState.isLoadingServices
                ? const Center(child: CircularProgressIndicator())
                : bookingState.services.isEmpty
                    ? const _EmptyServicesPlaceholder()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMD),
                        itemCount: bookingState.services.length,
                        itemBuilder: (context, index) {
                          final service = bookingState.services[index];
                          final isSelected = bookingState.selectedServiceIds.contains(service.id);
                          return _ServiceCard(
                            service: service,
                            isSelected: isSelected,
                            onChanged: (value) => bookingNotifier.toggleService(service.id),
                          );
                        },
                      ),
          ),

          // Итоговая сумма
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Итого:',
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
                  if (totalDuration > 0) ...[
                    const SizedBox(height: AppConstants.spacingSM),
                    Text(
                      'Время выполнения: $totalDuration мин',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                  ],
                  const SizedBox(height: AppConstants.spacingLG),
                  DesignSystemButton(
                    text: 'Далее',
                    onPressed: bookingState.hasSelectedServices
                        ? () => context.go('/home/booking/date-time/$specialistId')
                        : null,
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

class _ServiceCard extends StatelessWidget {
  final FirestoreSpecialistService service;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const _ServiceCard({
    required this.service,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(
          color: isSelected ? AppConstants.primaryColor : AppConstants.borderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
        controlAffinity: ListTileControlAffinity.trailing,
        title: Text(
          service.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((service.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                service.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingSM,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  ),
                  child: Text(
                    '${service.price.toStringAsFixed(0)} сум',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingSM,
                    vertical: AppConstants.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  ),
                  child: Text(
                    '${service.durationMinutes} мин',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyServicesPlaceholder extends StatelessWidget {
  const _EmptyServicesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 80,
              color: AppConstants.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: AppConstants.spacingLG),
            Text(
              'Услуги пока не добавлены',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Свяжитесь со специалистом для уточнения списка услуг.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textSecondary,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
