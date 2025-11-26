import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Добавляем интерцептор для авторизации
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Токен истек, нужно перелогиниться
            _authToken = null;
          }
          handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // Auth endpoints
  Future<Map<String, dynamic>> sendSms(String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/send-sms', data: {
        'phone_number': phoneNumber,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifySms(String phoneNumber, String code) async {
    try {
      final response = await _dio.post('/auth/verify-sms', data: {
        'phone_number': phoneNumber,
        'code': code,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String name,
    required String userType,
    String? email,
    String? category,
    String? description,
    double? pricePerHour,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'phone_number': phoneNumber,
        'name': name,
        'user_type': userType,
        'email': email,
        'category': category,
        'description': description,
        'price_per_hour': pricePerHour,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'phone_number': phoneNumber,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // User endpoints
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/user/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Specialist endpoints
  Future<List<Map<String, dynamic>>> getSpecialistsByCategory(String categoryId) async {
    try {
      final response = await _dio.get('/specialists', queryParameters: {
        'category': categoryId,
      });
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getSpecialistById(String specialistId) async {
    try {
      final response = await _dio.get('/specialists/$specialistId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateSpecialistProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/specialists/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Order endpoints
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/orders', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _dio.patch('/orders/$orderId/status', data: {
        'status': status,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Review endpoints
  Future<List<Map<String, dynamic>>> getReviews(String specialistId) async {
    try {
      final response = await _dio.get('/reviews', queryParameters: {
        'specialist_id': specialistId,
      });
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/reviews', data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Utility methods
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Ошибка соединения. Проверьте интернет-соединение.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Неизвестная ошибка';
        
        switch (statusCode) {
          case 400:
            return 'Неверный запрос: $message';
          case 401:
            return 'Необходима авторизация';
          case 403:
            return 'Доступ запрещен';
          case 404:
            return 'Ресурс не найден';
          case 422:
            return 'Ошибка валидации: $message';
          case 500:
            return 'Внутренняя ошибка сервера';
          default:
            return 'Ошибка сервера: $message';
        }
      case DioExceptionType.cancel:
        return 'Запрос отменен';
      case DioExceptionType.unknown:
        return 'Неизвестная ошибка. Проверьте интернет-соединение.';
      default:
        return 'Произошла ошибка: ${error.message}';
    }
  }
}