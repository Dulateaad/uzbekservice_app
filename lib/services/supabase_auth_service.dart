import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  final SupabaseClient _client = SupabaseConfig.client;

  /// Отправляет SMS код на указанный номер
  /// Примечание: Supabase не имеет встроенной SMS аутентификации
  /// Можно использовать Twilio или другой сервис через Edge Functions
  Future<Map<String, dynamic>> sendSmsCode(String phoneNumber) async {
    try {
      // Для Supabase нужно использовать Edge Function или внешний сервис
      // Пример через Supabase Edge Function:
      final response = await _client.functions.invoke(
        'send-sms-code',
        body: {'phone': phoneNumber},
      );

      if (response.status == 200) {
        return {
          'success': true,
          'message': 'SMS код отправлен',
          'verificationId': response.data['verification_id'],
        };
      } else {
        throw Exception('Ошибка отправки SMS: ${response.data}');
      }
    } catch (e) {
      print('Ошибка отправки SMS: $e');
      // Fallback: можно использовать внешний SMS сервис
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  String? _verificationId;

  /// Проверяет SMS код и аутентифицирует пользователя
  Future<bool> verifySmsCode(String phoneNumber, String smsCode) async {
    try {
      // Используем verifyOTP для проверки SMS кода
      final response = await _client.auth.verifyOTP(
        phone: phoneNumber,
        token: smsCode,
        type: OtpType.sms,
      );

      if (response.user != null) {
        print('SMS код успешно проверен');
        return true;
      }
      return false;
    } catch (e) {
      print('Ошибка проверки SMS кода: $e');
      // Альтернативный способ через Edge Function
      try {
        final response = await _client.functions.invoke(
          'verify-sms-code',
          body: {
            'phone': phoneNumber,
            'code': smsCode,
            'verification_id': _verificationId,
          },
        );
        return response.status == 200;
      } catch (e2) {
        print('Ошибка проверки через Edge Function: $e2');
        return false;
      }
    }
  }

  /// Аутентификация через OTP (One-Time Password)
  Future<Map<String, dynamic>> signInWithOtp(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phoneNumber,
      );
      return {
        'success': true,
        'message': 'OTP код отправлен на $phoneNumber',
      };
    } catch (e) {
      print('Ошибка отправки OTP: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Проверка OTP кода
  Future<bool> verifyOtp(String phoneNumber, String token) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
      );

      return response.user != null;
    } catch (e) {
      print('Ошибка проверки OTP: $e');
      return false;
    }
  }

  /// Получает текущего пользователя
  User? get currentUser => _client.auth.currentUser;

  /// Выход из системы
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _verificationId = null;
      print('Пользователь вышел из системы');
    } catch (e) {
      print('Ошибка выхода: $e');
      rethrow;
    }
  }

  /// Проверяет, аутентифицирован ли пользователь
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Получает ID текущего пользователя
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Обновляет профиль пользователя
  Future<void> updateUser({
    String? email,
    String? phone,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(
          email: email,
          phone: phone,
          data: data,
        ),
      );
      print('Профиль пользователя обновлен');
    } catch (e) {
      print('Ошибка обновления профиля: $e');
      rethrow;
    }
  }
}

