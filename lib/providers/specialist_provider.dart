import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/specialist_model.dart';

class SpecialistState {
  final List<Specialist> specialists;
  final Specialist? selectedSpecialist;
  final bool isLoading;
  final String? error;

  const SpecialistState({
    this.specialists = const [],
    this.selectedSpecialist,
    this.isLoading = false,
    this.error,
  });

  SpecialistState copyWith({
    List<Specialist>? specialists,
    Specialist? selectedSpecialist,
    bool? isLoading,
    String? error,
  }) {
    return SpecialistState(
      specialists: specialists ?? this.specialists,
      selectedSpecialist: selectedSpecialist ?? this.selectedSpecialist,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SpecialistNotifier extends StateNotifier<SpecialistState> {
  SpecialistNotifier() : super(const SpecialistState());

  Future<void> loadSpecialistsByCategory(String categoryId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Здесь будет логика загрузки специалистов
      await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
      
      // Создаем тестовых специалистов
      final specialists = List.generate(5, (index) {
        return Specialist(
          id: 'specialist_$index',
          userId: 'user_$index',
          name: 'Специалист ${index + 1}',
          category: categoryId,
          description: 'Опытный специалист с ${index + 1} годами опыта',
          pricePerHour: 50000.0 + (index * 10000),
          location: 'Ташкент, Узбекистан',
          latitude: 41.2995,
          longitude: 69.2401,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
      
      state = state.copyWith(
        specialists: specialists,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadSpecialistById(String specialistId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Здесь будет логика загрузки конкретного специалиста
      await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
      
      final specialist = Specialist(
        id: specialistId,
        userId: 'user_1',
        name: 'Ахмед Каримов',
        category: 'barber',
        description: 'Опытный барбер с 5 годами опыта. Специализируюсь на современных стрижках и уходе за бородой.',
        pricePerHour: 60000.0,
        photos: ['photo1.jpg', 'photo2.jpg'],
        rating: 4.8,
        reviewCount: 24,
        location: 'Ташкент, Чилонзар',
        latitude: 41.2995,
        longitude: 69.2401,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(
        selectedSpecialist: specialist,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSelectedSpecialist() {
    state = state.copyWith(selectedSpecialist: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final specialistProvider = StateNotifierProvider<SpecialistNotifier, SpecialistState>((ref) {
  return SpecialistNotifier();
});