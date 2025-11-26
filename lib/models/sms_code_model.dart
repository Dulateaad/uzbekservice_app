class SmsCode {
  final String id;
  final String phoneNumber;
  final String code;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final int attempts;

  SmsCode({
    required this.id,
    required this.phoneNumber,
    required this.code,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
    this.attempts = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'code': code,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isUsed': isUsed ? 1 : 0,
      'attempts': attempts,
    };
  }

  factory SmsCode.fromMap(Map<String, dynamic> map) {
    return SmsCode(
      id: map['id'],
      phoneNumber: map['phoneNumber'],
      code: map['code'],
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: DateTime.parse(map['expiresAt']),
      isUsed: map['isUsed'] == 1,
      attempts: map['attempts'],
    );
  }

  SmsCode copyWith({
    String? id,
    String? phoneNumber,
    String? code,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
    int? attempts,
  }) {
    return SmsCode(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      code: code ?? this.code,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      attempts: attempts ?? this.attempts,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get canAttempt => attempts < 3 && !isExpired && !isUsed;
}
