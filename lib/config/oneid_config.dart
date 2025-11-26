/// Конфигурация для OneID OAuth2 интеграции
class OneIdConfig {
  // URL вашего бэкенда на Render
  // TODO: Замените на ваш актуальный URL после деплоя
  static const String backendUrl = 'https://odo-oneid-backend.onrender.com';
  
  // OAuth endpoints
  static const String loginEndpoint = '$backendUrl/api/oneid/login';
  static const String callbackEndpoint = '$backendUrl/api/oneid/callback';
  static const String userInfoEndpoint = '$backendUrl/api/oneid/user';
  
  // Mobile app redirect scheme
  static const String redirectScheme = 'odouzapp';
  static const String redirectUri = '$redirectScheme://oneid/callback';
  
  // OneID scopes
  static const List<String> scopes = ['openid', 'profile', 'email'];
  
  // Timeout settings
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Проверка, является ли URL callback от OneID
  static bool isOneIdCallback(String url) {
    return url.startsWith(redirectUri);
  }
  
  /// Извлечение кода из callback URL
  static String? extractCodeFromCallback(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters['code'];
  }
  
  /// Извлечение ошибки из callback URL
  static String? extractErrorFromCallback(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters['error'] ?? uri.queryParameters['error_description'];
  }
}
