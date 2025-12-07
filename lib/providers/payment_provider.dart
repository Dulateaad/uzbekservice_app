import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/click_payment_service.dart';

/// Состояние провайдера оплаты
class PaymentState {
  final bool isLoading;
  final PaymentStatus? status;
  final ClickTransaction? currentTransaction;
  final List<SavedCard> savedCards;
  final List<ClickTransaction> paymentHistory;
  final String? error;
  final PaymentMethod selectedMethod;

  const PaymentState({
    this.isLoading = false,
    this.status,
    this.currentTransaction,
    this.savedCards = const [],
    this.paymentHistory = const [],
    this.error,
    this.selectedMethod = PaymentMethod.click,
  });

  PaymentState copyWith({
    bool? isLoading,
    PaymentStatus? status,
    ClickTransaction? currentTransaction,
    List<SavedCard>? savedCards,
    List<ClickTransaction>? paymentHistory,
    String? error,
    PaymentMethod? selectedMethod,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      currentTransaction: currentTransaction ?? this.currentTransaction,
      savedCards: savedCards ?? this.savedCards,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      error: error,
      selectedMethod: selectedMethod ?? this.selectedMethod,
    );
  }
}

/// Нотификатор для управления оплатой
class PaymentNotifier extends StateNotifier<PaymentState> {
  final ClickPaymentService _paymentService;
  final String userId;

  PaymentNotifier({
    required ClickPaymentService paymentService,
    required this.userId,
  })  : _paymentService = paymentService,
        super(const PaymentState());

  /// Загрузить сохраненные карты
  Future<void> loadSavedCards() async {
    state = state.copyWith(isLoading: true);
    try {
      final cards = await _paymentService.getSavedCards(userId);
      state = state.copyWith(
        savedCards: cards,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Загрузить историю платежей
  Future<void> loadPaymentHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final history = await _paymentService.getPaymentHistory(userId);
      state = state.copyWith(
        paymentHistory: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Создать транзакцию
  Future<ClickTransaction?> createTransaction({
    required String orderId,
    required double amount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transaction = await _paymentService.createTransaction(
        orderId: orderId,
        amount: amount,
        userId: userId,
      );
      state = state.copyWith(
        currentTransaction: transaction,
        status: PaymentStatus.pending,
        isLoading: false,
      );
      return transaction;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }

  /// Получить URL для оплаты через Click
  String getClickPaymentUrl({
    required String orderId,
    required double amount,
    String? cardType,
  }) {
    return _paymentService.getPaymentUrl(
      orderId: orderId,
      amount: amount,
      cardType: cardType,
    );
  }

  /// Проверить статус платежа
  Future<void> checkPaymentStatus(String transactionId) async {
    state = state.copyWith(isLoading: true);
    try {
      final transaction = await _paymentService.checkPaymentStatus(transactionId);
      if (transaction != null) {
        state = state.copyWith(
          currentTransaction: transaction,
          status: transaction.status,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Обновить статус платежа
  Future<void> updatePaymentStatus({
    required String transactionId,
    required PaymentStatus status,
    String? errorMessage,
  }) async {
    try {
      await _paymentService.updatePaymentStatus(
        transactionId: transactionId,
        status: status,
        errorMessage: errorMessage,
      );
      state = state.copyWith(status: status);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Отменить платеж
  Future<bool> cancelPayment(String transactionId) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _paymentService.cancelPayment(transactionId);
      if (success) {
        state = state.copyWith(
          status: PaymentStatus.cancelled,
          isLoading: false,
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Сохранить карту
  Future<void> saveCard(SavedCard card) async {
    try {
      await _paymentService.saveCard(
        userId: userId,
        card: card,
      );
      await loadSavedCards();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Удалить карту
  Future<void> deleteCard(String cardId) async {
    try {
      await _paymentService.deleteCard(
        userId: userId,
        cardId: cardId,
      );
      await loadSavedCards();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Установить карту как основную
  Future<void> setCardAsPrimary(String cardId) async {
    try {
      await _paymentService.setCardAsPrimary(
        userId: userId,
        cardId: cardId,
      );
      await loadSavedCards();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Выбрать способ оплаты
  void selectPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  /// Запросить возврат средств
  Future<bool> requestRefund({
    required String transactionId,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _paymentService.requestRefund(
        transactionId: transactionId,
        reason: reason,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  /// Сбросить состояние
  void reset() {
    state = const PaymentState();
  }

  /// Очистить ошибку
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Провайдер сервиса оплаты
final clickPaymentServiceProvider = Provider<ClickPaymentService>((ref) {
  return ClickPaymentService();
});

/// Провайдер состояния оплаты
final paymentProvider = StateNotifierProvider.family<PaymentNotifier, PaymentState, String>(
  (ref, userId) {
    final paymentService = ref.watch(clickPaymentServiceProvider);
    return PaymentNotifier(
      paymentService: paymentService,
      userId: userId,
    );
  },
);

/// Провайдер сохраненных карт
final savedCardsProvider = FutureProvider.family<List<SavedCard>, String>(
  (ref, userId) async {
    final paymentService = ref.watch(clickPaymentServiceProvider);
    return paymentService.getSavedCards(userId);
  },
);

/// Провайдер истории платежей
final paymentHistoryProvider = FutureProvider.family<List<ClickTransaction>, String>(
  (ref, userId) async {
    final paymentService = ref.watch(clickPaymentServiceProvider);
    return paymentService.getPaymentHistory(userId);
  },
);

