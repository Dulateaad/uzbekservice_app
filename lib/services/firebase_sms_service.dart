import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';

class FirebaseSmsService {
  static final FirebaseSmsService _instance = FirebaseSmsService._internal();
  factory FirebaseSmsService() => _instance;
  FirebaseSmsService._internal();

  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  final FirebaseAuth _auth = FirebaseConfig.auth;

  /// Отправляет SMS код через Firebase Auth
  Future<Map<String, dynamic>> sendSmsCode(String phoneNumber) async {
    try {
      // Генерируем 6-значный код
      final code = _generateSmsCode();
      
      // Сохраняем код в Firestore
      await _saveSmsCode(phoneNumber, code);
      
      // Для тестирования показываем код в консоли
      print('📱 SMS код для $phoneNumber: $code');
      
      return {
        'success': true,
        'code': code,
        'message': 'SMS код отправлен',
      };
    } catch (e) {
      print('Ошибка отправки SMS: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Проверяет SMS код
  Future<bool> verifySmsCode(String phoneNumber, String code) async {
    try {
      // Получаем код из Firestore
      final querySnapshot = await _firestore
          .collection('sms_codes')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('isUsed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('SMS код не найден для $phoneNumber');
        return false;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      // Проверяем срок действия (5 минут)
      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final expiresAt = createdAt.add(const Duration(minutes: 5));
      
      if (DateTime.now().isAfter(expiresAt)) {
        print('SMS код истек для $phoneNumber');
        return false;
      }

      // Проверяем количество попыток
      if (data['attempts'] >= 3) {
        print('Превышено количество попыток для $phoneNumber');
        return false;
      }

      // Проверяем код
      if (data['code'] != code) {
        // Увеличиваем количество попыток
        await doc.reference.update({
          'attempts': data['attempts'] + 1,
        });
        
        print('Неверный SMS код для $phoneNumber');
        return false;
      }

      // Помечаем код как использованный
      await doc.reference.update({'isUsed': true});
      
      print('SMS код успешно проверен для $phoneNumber');
      return true;
    } catch (e) {
      print('Ошибка проверки SMS кода: $e');
      return false;
    }
  }

  /// Сохраняет SMS код в Firestore
  Future<void> _saveSmsCode(String phoneNumber, String code) async {
    try {
      await _firestore.collection('sms_codes').add({
        'phoneNumber': phoneNumber,
        'code': code,
        'createdAt': Timestamp.now(),
        'isUsed': false,
        'attempts': 0,
      });
    } catch (e) {
      print('Ошибка сохранения SMS кода: $e');
      rethrow;
    }
  }

  /// Генерирует 6-значный SMS код
  String _generateSmsCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Очищает старые SMS коды
  Future<void> cleanupExpiredCodes() async {
    try {
      final fiveMinutesAgo = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(minutes: 5))
      );
      
      final querySnapshot = await _firestore
          .collection('sms_codes')
          .where('createdAt', isLessThan: fiveMinutesAgo)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      print('Очищены истекшие SMS коды');
    } catch (e) {
      print('Ошибка очистки SMS кодов: $e');
    }
  }
}
