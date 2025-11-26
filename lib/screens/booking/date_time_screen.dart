import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../models/firestore_models.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/design_system_button.dart';

class DateTimeScreen extends ConsumerWidget {
  final String specialistId;

  const DateTimeScreen({
    super.key,
    required this.specialistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider(specialistId));
    final bookingNotifier = ref.read(bookingProvider(specialistId).notifier);

    final selectedServices = bookingState.selectedServices;
    final totalDuration = bookingState.totalDurationMinutes;
    final selectedDate = bookingState.selectedDate ?? DateTime.now().add(const Duration(days: 1));
    final selectedTimeSlot = bookingState.selectedTimeSlot;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Дата и время'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Хлебные крошки
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: Row(
              children: const [
                _Breadcrumb(text: 'Шаг 2 из 4', isActive: true),
                SizedBox(width: AppConstants.spacingSM),
                _Breadcrumb(text: 'Адрес'),
                SizedBox(width: AppConstants.spacingSM),
                _Breadcrumb(text: 'Подтверждение'),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectedServicesSummary(selectedServices, context),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildCalendar(
                    context: context,
                    selectedDate: selectedDate,
                    onChanged: bookingNotifier.selectDate,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildTimeSlots(
                    context: context,
                    selectedTimeSlot: selectedTimeSlot,
                    onSelect: bookingNotifier.selectTimeSlot,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  _buildSessionInfo(totalDuration, context),
                ],
              ),
            ),
          ),

          // Кнопка далее
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
              child: DesignSystemButton(
                text: 'Далее',
                onPressed: selectedTimeSlot != null
                    ? () => context.go('/home/booking/address/$specialistId')
                    : null,
                type: ButtonType.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedServicesSummary(List<FirestoreSpecialistService> services, BuildContext context) {
    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(color: AppConstants.borderColor, width: 1),
        ),
        child: const Text(
          'Вы не выбрали услуги. Вернитесь назад и выберите хотя бы одну услугу.',
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }

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
            'Выбранные услуги',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.spacingMD),
          ...services.map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    '${service.durationMinutes} мин',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppConstants.textSecondary,
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

  Widget _buildCalendar({
    required BuildContext context,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onChanged,
  }) {
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
            'Выберите дату',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.spacingMD),
          SizedBox(
            height: 300,
            child: CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              onDateChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots({
    required BuildContext context,
    required String? selectedTimeSlot,
    required ValueChanged<String?> onSelect,
  }) {
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
            'Выберите время',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.spacingMD),
          Wrap(
            spacing: AppConstants.spacingSM,
            runSpacing: AppConstants.spacingSM,
            children: BookingNotifier.defaultTimeSlots.map((time) {
              final isSelected = selectedTimeSlot == time;
              final isAvailable = _isTimeSlotAvailable(time);

              return GestureDetector(
                onTap: isAvailable ? () => onSelect(isSelected ? null : time) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingMD,
                    vertical: AppConstants.spacingSM,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : isAvailable
                            ? AppConstants.surfaceColor
                            : AppConstants.borderColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(
                      color: isSelected
                          ? AppConstants.primaryColor
                          : isAvailable
                              ? AppConstants.borderColor
                              : AppConstants.borderColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppConstants.primaryContrastColor
                          : isAvailable
                              ? AppConstants.textPrimary
                              : AppConstants.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(int totalDuration, BuildContext context) {
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
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppConstants.primaryColor,
            size: 24,
          ),
          const SizedBox(width: AppConstants.spacingMD),
          Expanded(
            child: Text(
              'Сеанс будет забронирован на $totalDuration минут',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isTimeSlotAvailable(String time) {
    const unavailableSlots = ['12:00', '13:00', '18:00'];
    return !unavailableSlots.contains(time);
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
