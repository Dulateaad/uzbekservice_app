/// Модели для платежей через Click и другие платежные системы

enum PaymentStatus {
  pending,      // Ожидает оплаты
  processing,   // В процессе
  completed,    // Оплачено
  failed,       // Ошибка
  cancelled,    // Отменено
  refunded,     // Возврат
}

enum PaymentMethod {
  click,        // Click
  payme,        // Payme
  uzcard,       // Uzcard напрямую
  humo,         // Humo напрямую
  cash,         // Наличные
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.click:
        return 'Click';
      case PaymentMethod.payme:
        return 'Payme';
      case PaymentMethod.uzcard:
        return 'Uzcard';
      case PaymentMethod.humo:
        return 'Humo';
      case PaymentMethod.cash:
        return 'Наличные';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.click:
        return '💳';
      case PaymentMethod.payme:
        return '💰';
      case PaymentMethod.uzcard:
        return '💳';
      case PaymentMethod.humo:
        return '💳';
      case PaymentMethod.cash:
        return '💵';
    }
  }

  String get logoAsset {
    switch (this) {
      case PaymentMethod.click:
        return 'assets/images/click_logo.png';
      case PaymentMethod.payme:
        return 'assets/images/payme_logo.png';
      case PaymentMethod.uzcard:
        return 'assets/images/uzcard_logo.png';
      case PaymentMethod.humo:
        return 'assets/images/humo_logo.png';
      case PaymentMethod.cash:
        return '';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Ожидает оплаты';
      case PaymentStatus.processing:
        return 'Обрабатывается';
      case PaymentStatus.completed:
        return 'Оплачено';
      case PaymentStatus.failed:
        return 'Ошибка оплаты';
      case PaymentStatus.cancelled:
        return 'Отменено';
      case PaymentStatus.refunded:
        return 'Возвращено';
    }
  }
}

/// Модель транзакции Click
class ClickTransaction {
  final String transactionId;
  final String orderId;
  final double amount;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final Map<String, dynamic>? clickResponse;

  ClickTransaction({
    required this.transactionId,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.clickResponse,
  });

  factory ClickTransaction.fromJson(Map<String, dynamic> json) {
    return ClickTransaction(
      transactionId: json['transaction_id'] ?? '',
      orderId: json['order_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      errorMessage: json['error_message'],
      clickResponse: json['click_response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'order_id': orderId,
      'amount': amount,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'error_message': errorMessage,
      'click_response': clickResponse,
    };
  }

  ClickTransaction copyWith({
    String? transactionId,
    String? orderId,
    double? amount,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? clickResponse,
  }) {
    return ClickTransaction(
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      clickResponse: clickResponse ?? this.clickResponse,
    );
  }
}

/// Параметры для создания платежа Click
class ClickPaymentParams {
  final String merchantId;
  final String serviceId;
  final String transactionParam; // Уникальный ID заказа
  final double amount;
  final String returnUrl;
  final String? cardType; // uzcard, humo, visa, mastercard

  ClickPaymentParams({
    required this.merchantId,
    required this.serviceId,
    required this.transactionParam,
    required this.amount,
    required this.returnUrl,
    this.cardType,
  });

  /// Генерация URL для оплаты через Click
  String get paymentUrl {
    final baseUrl = 'https://my.click.uz/services/pay';
    final params = <String, String>{
      'service_id': serviceId,
      'merchant_id': merchantId,
      'amount': amount.toStringAsFixed(0),
      'transaction_param': transactionParam,
      'return_url': returnUrl,
    };
    
    if (cardType != null) {
      params['card_type'] = cardType!;
    }

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseUrl?$queryString';
  }
}

/// Сохраненная карта пользователя
class SavedCard {
  final String id;
  final String cardNumber; // Последние 4 цифры
  final String cardType; // uzcard, humo, visa, mastercard
  final String holderName;
  final String expiryDate;
  final bool isPrimary;
  final String? clickCardToken; // Токен для повторных платежей

  SavedCard({
    required this.id,
    required this.cardNumber,
    required this.cardType,
    required this.holderName,
    required this.expiryDate,
    this.isPrimary = false,
    this.clickCardToken,
  });

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    return SavedCard(
      id: json['id'] ?? '',
      cardNumber: json['card_number'] ?? '',
      cardType: json['card_type'] ?? 'uzcard',
      holderName: json['holder_name'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      clickCardToken: json['click_card_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_number': cardNumber,
      'card_type': cardType,
      'holder_name': holderName,
      'expiry_date': expiryDate,
      'is_primary': isPrimary,
      'click_card_token': clickCardToken,
    };
  }

  String get maskedNumber => '•••• •••• •••• $cardNumber';

  String get cardTypeDisplayName {
    switch (cardType.toLowerCase()) {
      case 'uzcard':
        return 'Uzcard';
      case 'humo':
        return 'Humo';
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      default:
        return cardType;
    }
  }
}

