import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/firestore_models.dart';
import '../services/firestore_service.dart';
import '../services/test_data_service.dart';

class BookingState {
  final String specialistId;
  final FirestoreUser? specialist;
  final List<FirestoreSpecialistService> services;
  final Set<String> selectedServiceIds;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String addressLine;
  final String? additionalNote;
  final Map<String, double>? location;
  final bool isLoadingServices;
  final bool isSubmitting;
  final String? errorMessage;

  const BookingState({
    required this.specialistId,
    this.specialist,
    this.services = const [],
    this.selectedServiceIds = const {},
    this.selectedDate,
    this.selectedTimeSlot,
    this.addressLine = '',
    this.additionalNote,
    this.location,
    this.isLoadingServices = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  List<FirestoreSpecialistService> get selectedServices => services
      .where((service) => selectedServiceIds.contains(service.id))
      .toList();

  double get totalPrice => selectedServices.fold(0.0, (sum, service) => sum + service.price);

  int get totalDurationMinutes => selectedServices.fold(0, (sum, service) => sum + service.durationMinutes);

  bool get hasSelectedServices => selectedServiceIds.isNotEmpty;

  bool get canProceedToConfirmation => hasSelectedServices && selectedDate != null && selectedTimeSlot != null && addressLine.isNotEmpty;

  bool get canProceed => canProceedToConfirmation;

  BookingState copyWith({
    FirestoreUser? specialist,
    List<FirestoreSpecialistService>? services,
    Set<String>? selectedServiceIds,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? selectedTimeSlot,
    bool clearSelectedTimeSlot = false,
    String? addressLine,
    String? additionalNote,
    Map<String, double>? location,
    bool clearLocation = false,
    bool? isLoadingServices,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingState(
      specialistId: specialistId,
      specialist: specialist ?? this.specialist,
      services: services ?? this.services,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      selectedTimeSlot: clearSelectedTimeSlot ? null : (selectedTimeSlot ?? this.selectedTimeSlot),
      addressLine: addressLine ?? this.addressLine,
      additionalNote: additionalNote ?? this.additionalNote,
      location: clearLocation ? null : (location ?? this.location),
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier(this.ref, String specialistId)
      : super(BookingState(specialistId: specialistId)) {
    _initialize();
  }

  final Ref ref;

  static const List<String> defaultTimeSlots = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
  ];

  Future<void> _initialize() async {
    state = state.copyWith(isLoadingServices: true, clearError: true);

    await Future.wait([
      _loadSpecialist(),
      _loadServices(),
    ]);

    state = state.copyWith(isLoadingServices: false);
  }

  Future<void> _loadSpecialist() async {
    try {
      final specialist = await FirestoreService.getUserById(state.specialistId);
      if (specialist != null) {
        state = state.copyWith(specialist: specialist);
        return;
      }
    } catch (e) {
      // ignore, try fallback
      print('⚠️ Ошибка загрузки специалиста для бронирования: $e');
    }

    final fallbackSpecialist = TestDataService.getTestSpecialists().firstWhere(
      (specialist) => specialist.id == state.specialistId,
      orElse: () => TestDataService.getTestSpecialists().first,
    );
    state = state.copyWith(specialist: fallbackSpecialist);
  }

  Future<void> _loadServices() async {
    try {
      final services = await FirestoreService.getSpecialistServices(state.specialistId);

      if (services.isNotEmpty) {
        state = state.copyWith(services: services);
        return;
      }

      // Если Firestore вернул пусто, используем тестовые данные
      final fallbackServices = TestDataService.getTestServicesForSpecialist(state.specialistId);
      state = state.copyWith(services: fallbackServices);
    } catch (e) {
      final fallbackServices = TestDataService.getTestServicesForSpecialist(state.specialistId);
      state = state.copyWith(
        services: fallbackServices,
        errorMessage: 'Не удалось загрузить услуги: $e',
      );
    }
  }

  void toggleService(String serviceId) {
    final updated = Set<String>.from(state.selectedServiceIds);
    if (updated.contains(serviceId)) {
      updated.remove(serviceId);
    } else {
      updated.add(serviceId);
    }

    state = state.copyWith(
      selectedServiceIds: updated,
      clearError: true,
    );
  }

  void selectDate(DateTime date) {
    if (state.selectedDate != date) {
      state = state.copyWith(
        selectedDate: date,
        clearSelectedTimeSlot: true,
        clearError: true,
      );
    }
  }

  void selectTimeSlot(String? timeSlot) {
    state = state.copyWith(
      selectedTimeSlot: timeSlot,
      clearError: true,
    );
  }

  void setAddress(String address) {
    state = state.copyWith(addressLine: address, clearError: true);
  }

  void setAdditionalNote(String? note) {
    state = state.copyWith(additionalNote: note, clearError: true);
  }

  void setLocation(Map<String, double>? location) {
    state = state.copyWith(location: location, clearLocation: location == null, clearError: true);
  }

  void setSpecialist(FirestoreUser specialist) {
    state = state.copyWith(specialist: specialist);
  }

  void resetSelection() {
    state = state.copyWith(
      selectedServiceIds: <String>{},
      clearSelectedDate: true,
      clearSelectedTimeSlot: true,
      addressLine: '',
      additionalNote: null,
      clearLocation: true,
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  List<FirestoreSpecialistService> get availableServices => state.services;

  List<FirestoreSpecialistService> get selectedServices => state.selectedServices;

  double get totalPrice => state.totalPrice;

  int get totalDurationMinutes => state.totalDurationMinutes;

  bool get hasSelectedServices => state.hasSelectedServices;

  bool get canProceed => state.canProceedToConfirmation;

  FirestoreUser? get specialist => state.specialist;

  Future<FirestoreOrder?> createOrder({
    required String clientId,
    String? customAddress,
    Map<String, dynamic>? location,
  }) async {
    if (!state.hasSelectedServices) {
      throw StateError('Выберите хотя бы одну услугу');
    }

    if (state.selectedDate == null || state.selectedTimeSlot == null) {
      throw StateError('Выберите дату и время');
    }

    final address = customAddress ?? state.addressLine;
    if (address.isEmpty) {
      throw StateError('Укажите адрес');
    }

    final scheduledDateTime = _combineDateAndTime(state.selectedDate!, state.selectedTimeSlot!);

    final specialist = state.specialist ??
        await FirestoreService.getUserById(state.specialistId) ??
        TestDataService.getTestSpecialists().firstWhere(
          (user) => user.id == state.specialistId,
          orElse: () => TestDataService.getTestSpecialists().first,
        );

    final totalPrice = state.totalPrice;
    final totalDuration = state.totalDurationMinutes;
    final orderServices = state.selectedServices
        .map((service) => OrderServiceItem(
              id: service.id,
              name: service.name,
              price: service.price,
              durationMinutes: service.durationMinutes,
              description: service.description,
              category: service.category,
            ))
        .toList();

    final description = orderServices.map((service) => service.name).join(', ');

    final normalizedLocation = location != null ? Map<String, dynamic>.from(location) : state.location != null ? Map<String, dynamic>.from(state.location!) : null;

    final order = FirestoreOrder(
      id: '',
      clientId: clientId,
      specialistId: specialist.id,
      category: specialist.category ?? (orderServices.isNotEmpty ? orderServices.first.category ?? 'general' : 'general'),
      title: 'Заказ услуг специалиста',
      description: description,
      status: 'pending',
      price: totalPrice,
      address: address,
      location: normalizedLocation,
      scheduledDate: scheduledDateTime,
      timeSlot: state.selectedTimeSlot,
      totalDurationMinutes: totalDuration,
      services: orderServices,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: state.additionalNote,
      images: null,
      rating: null,
      review: null,
    );

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final savedOrder = await FirestoreService.createOrder(order);
      return savedOrder;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Ошибка создания заказа: $e');
      rethrow;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  DateTime _combineDateAndTime(DateTime date, String timeSlot) {
    final parts = timeSlot.split(':');
    final hour = int.tryParse(parts.first) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

final bookingProvider = StateNotifierProvider.family<BookingNotifier, BookingState, String>((ref, specialistId) {
  return BookingNotifier(ref, specialistId);
});
