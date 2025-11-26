import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/oneid_config.dart';

/// Модель данных пользователя OneID
class OneIdUser {
  final String sub; // Subject (user ID from OneID)
  final String? pin; // ПИНФЛ
  final String? fullNameLatin;
  final String? fullNameCyrillic;
  final String? birthDate;
  final String? email;
  final String? phone;
  final Map<String, dynamic> rawData;

  OneIdUser({
    required this.sub,
    this.pin,
    this.fullNameLatin,
    this.fullNameCyrillic,
    this.birthDate,
    this.email,
    this.phone,
    required this.rawData,
  });

  factory OneIdUser.fromJson(Map<String, dynamic> json) {
    return OneIdUser(
      sub: json['sub'] ?? '',
      pin: json['pin'] ?? json['pinfl'],
      fullNameLatin: json['full_name'] ?? json['full_name_latin'],
      fullNameCyrillic: json['full_name_cyrillic'],
      birthDate: json['birth_date'],
      email: json['email'],
      phone: json['phone'] ?? json['mobile'],
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'pin': pin,
      'fullNameLatin': fullNameLatin,
      'fullNameCyrillic': fullNameCyrillic,
      'birthDate': birthDate,
      'email': email,
      'phone': phone,
      'rawData': rawData,
    };
  }
}

/// Результат авторизации OneID
class OneIdAuthResult {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final OneIdUser? user;
  final String? error;

  OneIdAuthResult({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.error,
  });

  factory OneIdAuthResult.success({
    required String accessToken,
    String? refreshToken,
    required OneIdUser user,
  }) {
    return OneIdAuthResult(
      success: true,
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  factory OneIdAuthResult.failure(String error) {
    return OneIdAuthResult(
      success: false,
      error: error,
    );
  }
}

/// Сервис для работы с OneID OAuth2
class OneIdService {
  static final OneIdService _instance = OneIdService._internal();
  factory OneIdService() => _instance;
  OneIdService._internal();

  String? _pendingState;

  /// Генерация случайной строки для state (CSRF protection)
  String _generateState() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 12345).toString();
    _pendingState = random;
    return random;
  }

  /// Начало OAuth2 flow - открытие браузера для авторизации
  Future<bool> startAuthFlow() async {
    try {
      final state = _generateState();
      
      // Формируем URL для авторизации
      final authUrl = Uri.parse(OneIdConfig.loginEndpoint).replace(
        queryParameters: {
          'redirect_uri': OneIdConfig.redirectUri,
          'state': state,
        },
      );

      print('🔐 Открытие OneID авторизации: $authUrl');

      // Открываем браузер для авторизации
      final launched = await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        print('❌ Не удалось открыть браузер');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Ошибка при запуске OneID авторизации: $e');
      return false;
    }
  }

  /// Обработка callback от OneID (вызывается из deep link)
  Future<OneIdAuthResult> handleCallback(String callbackUrl) async {
    try {
      print('📥 Получен callback: $callbackUrl');

      // Проверяем, что это наш callback
      if (!OneIdConfig.isOneIdCallback(callbackUrl)) {
        return OneIdAuthResult.failure('Неверный callback URL');
      }

      // Извлекаем параметры
      final code = OneIdConfig.extractCodeFromCallback(callbackUrl);
      final error = OneIdConfig.extractErrorFromCallback(callbackUrl);

      if (error != null) {
        print('❌ Ошибка от OneID: $error');
        return OneIdAuthResult.failure(error);
      }

      if (code == null) {
        return OneIdAuthResult.failure('Код авторизации не получен');
      }

      print('✅ Получен код авторизации: ${code.substring(0, 10)}...');

      // Обмениваем код на токен через наш бэкенд
      return await _exchangeCodeForToken(code);
    } catch (e) {
      print('❌ Ошибка обработки callback: $e');
      return OneIdAuthResult.failure('Ошибка обработки ответа: $e');
    }
  }

  /// Обмен кода на access token
  Future<OneIdAuthResult> _exchangeCodeForToken(String code) async {
    try {
      final url = Uri.parse(OneIdConfig.callbackEndpoint);
      
      print('🔄 Обмен кода на токен...');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'redirect_uri': OneIdConfig.redirectUri,
        }),
      ).timeout(OneIdConfig.requestTimeout);

      print('📡 Ответ от бэкенда: ${response.statusCode}');

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        return OneIdAuthResult.failure(
          errorData['error'] ?? 'Ошибка получения токена',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final userData = data['user'] as Map<String, dynamic>?;

      if (accessToken == null || userData == null) {
        return OneIdAuthResult.failure('Некорректный ответ от сервера');
      }

      final user = OneIdUser.fromJson(userData);

      print('✅ Пользователь авторизован: ${user.fullNameLatin}');

      return OneIdAuthResult.success(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } catch (e) {
      print('❌ Ошибка обмена кода на токен: $e');
      return OneIdAuthResult.failure('Ошибка связи с сервером: $e');
    }
  }

  /// Получение информации о пользователе по токену
  Future<OneIdUser?> getUserInfo(String accessToken) async {
    try {
      final url = Uri.parse(OneIdConfig.userInfoEndpoint);
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(OneIdConfig.requestTimeout);

      if (response.statusCode != 200) {
        print('❌ Ошибка получения данных пользователя: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return OneIdUser.fromJson(data);
    } catch (e) {
      print('❌ Ошибка получения данных пользователя: $e');
      return null;
    }
  }

  /// Очистка состояния
  void reset() {
    _pendingState = null;
  }
}
