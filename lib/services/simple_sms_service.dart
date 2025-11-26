import 'dart:math';

class SimpleSmsService {
  static final SimpleSmsService _instance = SimpleSmsService._internal();
  factory SimpleSmsService() => _instance;
  SimpleSmsService._internal();

  // Хранилище кодов в памяти (для тестирования)
  final Map<String, String> _smsCodes = {};
  final Map<String, DateTime> _codeTimestamps = {};

  /// Отправляет SMS код (симуляция)
  Future<bool> sendSmsCode(String phoneNumber) async {
    try {
      // Генерируем случайный 6-значный код
      final code = _generateSmsCode();
      
      // Сохраняем код
      _smsCodes[phoneNumber] = code;
      _codeTimestamps[phoneNumber] = DateTime.now();
      
      // Симулируем задержку отправки
      await Future.delayed(const Duration(seconds: 1));
      
      print('📱 SMS код отправлен на $phoneNumber: $code');
      print('💡 Для тестирования используйте код: $code');
      
      return true;
    } catch (e) {
      print('❌ Ошибка отправки SMS: $e');
      return false;
    }
  }

  /// Проверяет SMS код
  Future<bool> verifySmsCode(String phoneNumber, String code) async {
    try {
      print('🔍 SimpleSmsService: Проверяем код для номера: "$phoneNumber"');
      print('🔍 SimpleSmsService: Введенный код: "$code"');
      print('🔍 SimpleSmsService: Все сохраненные коды: $_smsCodes');
      print('🔍 SimpleSmsService: Все временные метки: $_codeTimestamps');
      
      // Проверяем тестовый код 123456
      if (code == '123456') {
        print('✅ Тестовый код 123456 принят для $phoneNumber');
        return true;
      }
      
      final storedCode = _smsCodes[phoneNumber];
      final timestamp = _codeTimestamps[phoneNumber];
      
      print('🔍 SimpleSmsService: Найденный код для $phoneNumber: "$storedCode"');
      print('🔍 SimpleSmsService: Временная метка: $timestamp');
      
      if (storedCode == null || timestamp == null) {
        print('❌ Код не найден для номера: $phoneNumber');
        return false;
      }
      
      // Проверяем срок действия кода (5 минут)
      final now = DateTime.now();
      final codeAge = now.difference(timestamp);
      
      print('🔍 SimpleSmsService: Возраст кода: ${codeAge.inMinutes} минут');
      
      if (codeAge.inMinutes > 5) {
        print('❌ Код истек для номера: $phoneNumber');
        _smsCodes.remove(phoneNumber);
        _codeTimestamps.remove(phoneNumber);
        return false;
      }
      
      // Проверяем код
      final isValid = storedCode == code;
      
      print('🔍 SimpleSmsService: Сравнение "$storedCode" == "$code" = $isValid');
      
      if (isValid) {
        print('✅ SMS код подтвержден для $phoneNumber');
        // Удаляем использованный код
        _smsCodes.remove(phoneNumber);
        _codeTimestamps.remove(phoneNumber);
      } else {
        print('❌ Неверный SMS код для $phoneNumber');
        print('❌ Ожидался: "$storedCode", получен: "$code"');
      }
      
      return isValid;
    } catch (e) {
      print('❌ Ошибка проверки SMS: $e');
      return false;
    }
  }

  /// Генерирует случайный SMS код
  String _generateSmsCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Очищает старые коды
  void _cleanupOldCodes() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _codeTimestamps.forEach((phone, timestamp) {
      if (now.difference(timestamp).inMinutes > 5) {
        keysToRemove.add(phone);
      }
    });
    
    for (final key in keysToRemove) {
      _smsCodes.remove(key);
      _codeTimestamps.remove(key);
    }
  }
}