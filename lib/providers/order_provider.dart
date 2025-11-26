import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';

class OrderState {
  final List<Order> orders;
  final Order? selectedOrder;
  final bool isLoading;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? orders,
    Order? selectedOrder,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(const OrderState());

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Здесь будет логика загрузки заказов
      await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
      
      // Создаем тестовые заказы
      final orders = List.generate(3, (index) {
        return Order(
          id: 'order_$index',
          clientId: 'client_1',
          specialistId: 'specialist_$index',
          title: 'Заказ ${index + 1}',
          description: 'Описание заказа ${index + 1}',
          address: 'Ташкент, ул. Навои ${index + 1}',
          latitude: 41.2995,
          longitude: 69.2401,
          scheduledDate: DateTime.now().add(Duration(days: index + 1)),
          estimatedHours: 2,
          totalPrice: 100000.0 + (index * 50000),
          status: index == 0 ? 'pending' : index == 1 ? 'confirmed' : 'completed',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
      
      state = state.copyWith(
        orders: orders,
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

  Future<void> loadOrderById(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Здесь будет логика загрузки конкретного заказа
      await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
      
      final order = Order(
        id: orderId,
        clientId: 'client_1',
        specialistId: 'specialist_1',
        title: 'Стрижка и бритье',
        description: 'Мужская стрижка и бритье бороды',
        address: 'Ташкент, ул. Навои 1',
        latitude: 41.2995,
        longitude: 69.2401,
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        estimatedHours: 2,
        totalPrice: 120000.0,
        status: 'confirmed',
        clientNotes: 'Пожалуйста, принесите свои инструменты',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(
        selectedOrder: order,
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

  Future<void> createOrder({
    required String specialistId,
    required String title,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required DateTime scheduledDate,
    required int estimatedHours,
    String? clientNotes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Здесь будет логика создания заказа
      await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
      
      final newOrder = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        clientId: 'client_1',
        specialistId: specialistId,
        title: title,
        description: description,
        address: address,
        latitude: latitude,
        longitude: longitude,
        scheduledDate: scheduledDate,
        estimatedHours: estimatedHours,
        totalPrice: estimatedHours * 50000.0, // Примерная цена
        status: 'pending',
        clientNotes: clientNotes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(
        orders: [newOrder, ...state.orders],
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

  Future<void> updateOrderStatus(String orderId, String status) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Здесь будет логика обновления статуса заказа
      await Future.delayed(const Duration(seconds: 1)); // Имитация запроса
      
      final updatedOrders = state.orders.map((order) {
        if (order.id == orderId) {
          return order.copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
        }
        return order;
      }).toList();
      
      state = state.copyWith(
        orders: updatedOrders,
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

  void clearSelectedOrder() {
    state = state.copyWith(selectedOrder: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});