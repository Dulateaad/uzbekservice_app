import 'dart:math';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sms_code_model.dart';
import '../database/database_helper.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Отправляет SMS код на указанный номер
  Future<SmsCode> sendSmsCode(String phoneNumber) async {
    try {
      // Проверяем разрешения
      final permission = await Permission.sms.status;
      if (!permission.isGranted) {
        await Permission.sms.request();
      }

      // Генерируем 6-значный код
      final code = _generateSmsCode();
      
      // Создаем объект SMS кода
      final smsCode = SmsCode(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: phoneNumber,
        code: code,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)), // Код действует 5 минут
      );

      // Сохраняем в базу данных
      await _databaseHelper.insertSmsCode(smsCode);

      // Отправляем SMS (реальная отправка)
      await _sendRealSms(phoneNumber, code);

      print('SMS код отправлен на $phoneNumber: $code');
      return smsCode;
    } catch (e) {
      print('Ошибка отправки SMS: $e');
      rethrow;
    }
  }

  /// Проверяет SMS код
  Future<bool> verifySmsCode(String phoneNumber, String code) async {
    try {
      final smsCode = await _databaseHelper.getSmsCode(phoneNumber);
      
      if (smsCode == null) {
        print('SMS код не найден для $phoneNumber');
        return false;
      }

      if (smsCode.isExpired) {
        print('SMS код истек для $phoneNumber');
        return false;
      }

      if (smsCode.isUsed) {
        print('SMS код уже использован для $phoneNumber');
        return false;
      }

      if (smsCode.attempts >= 3) {
        print('Превышено количество попыток для $phoneNumber');
        return false;
      }

      if (smsCode.code != code) {
        // Увеличиваем количество попыток
        final updatedSmsCode = smsCode.copyWith(attempts: smsCode.attempts + 1);
        await _databaseHelper.updateSmsCode(updatedSmsCode);
        print('Неверный SMS код для $phoneNumber');
        return false;
      }

      // Помечаем код как использованный
      final usedSmsCode = smsCode.copyWith(isUsed: true);
      await _databaseHelper.updateSmsCode(usedSmsCode);
      
      print('SMS код успешно проверен для $phoneNumber');
      return true;
    } catch (e) {
      print('Ошибка проверки SMS кода: $e');
      return false;
    }
  }

  /// Генерирует 6-значный SMS код
  String _generateSmsCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Отправляет реальное SMS
  Future<void> _sendRealSms(String phoneNumber, String code) async {
    try {
      // Для тестирования используем симуляцию
      // В реальном проекте здесь будет интеграция с SMS провайдером
      print('📱 Отправка SMS на $phoneNumber: Ваш код подтверждения: $code');
      
      // Имитация отправки SMS
      await Future.delayed(const Duration(seconds: 1));
      
      // В реальном проекте здесь будет:
      // await SmsSender.sendSms(
      //   SmsMessage(
      //     phoneNumber,
      //     'ODO.UZ: Ваш код подтверждения: $code. Код действителен 5 минут.',
      //   ),
      // );
      
    } catch (e) {
      print('Ошибка отправки SMS: $e');
      rethrow;
    }
  }

  /// Очищает старые SMS коды
  Future<void> cleanupExpiredCodes() async {
    try {
      await _databaseHelper.deleteExpiredSmsCodes();
      print('Очищены истекшие SMS коды');
    } catch (e) {
      print('Ошибка очистки SMS кодов: $e');
    }
  }
}
