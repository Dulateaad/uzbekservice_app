import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_config.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseConfig.auth;

  /// Отправляет SMS код на указанный номер
  Future<Map<String, dynamic>> sendSmsCode(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Автоматическая верификация (если приложение установлена на том же устройстве)
          print('Автоматическая верификация для $phoneNumber');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Ошибка верификации: ${e.message}');
          throw Exception('Ошибка отправки SMS: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print('SMS код отправлен на $phoneNumber');
          // Сохраняем verificationId для последующей проверки
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Тайм-аут получения SMS кода');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );

      return {
        'success': true,
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

  String? _verificationId;

  /// Проверяет SMS код
  Future<bool> verifySmsCode(String smsCode) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID не найден');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      
      print('SMS код успешно проверен');
      return true;
    } catch (e) {
      print('Ошибка проверки SMS кода: $e');
      return false;
    }
  }

  /// Получает текущего пользователя
  User? get currentUser => _auth.currentUser;

  /// Выход из системы
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _verificationId = null;
      print('Пользователь вышел из системы');
    } catch (e) {
      print('Ошибка выхода: $e');
      rethrow;
    }
  }

  /// Проверяет, аутентифицирован ли пользователь
  bool get isAuthenticated => _auth.currentUser != null;
}
