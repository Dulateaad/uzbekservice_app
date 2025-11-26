import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class SupabaseDatabaseService {
  static final SupabaseDatabaseService _instance = SupabaseDatabaseService._internal();
  factory SupabaseDatabaseService() => _instance;
  SupabaseDatabaseService._internal();

  final SupabaseClient _client = SupabaseConfig.client;

  /// Создает пользователя в Supabase
  Future<UserModel> createUser({
    required String phoneNumber,
    required String name,
    required String userType,
    String? email,
    String? category,
    String? description,
    double? pricePerHour,
    String? avatar,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не аутентифицирован');
      }

      final user = UserModel(
        id: currentUser.id,
        phoneNumber: phoneNumber,
        name: name,
        email: email,
        userType: userType,
        category: category,
        description: description,
        pricePerHour: pricePerHour,
        avatar: avatar,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
      );

      // Сохраняем в таблицу users
      // Преобразуем DateTime в строки для PostgreSQL
      final userMap = user.toMap();
      userMap['created_at'] = user.createdAt.toIso8601String();
      userMap['updated_at'] = user.updatedAt.toIso8601String();
      
      await _client
          .from('users')
          .insert(userMap);

      // Если специалист, создаем запись в таблице specialists
      if (userType == 'specialist') {
        await _client
            .from('specialists')
            .insert({
          'user_id': user.id,
          'phone_number': phoneNumber,
          'name': name,
          'email': email,
          'category': category,
          'description': description,
          'price_per_hour': pricePerHour,
          'avatar': avatar,
          'rating': 0.0,
          'total_reviews': 0,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Если клиент, создаем запись в таблице clients
        await _client
            .from('clients')
            .insert({
          'user_id': user.id,
          'phone_number': phoneNumber,
          'name': name,
          'email': email,
          'avatar': avatar,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      print('Пользователь создан в Supabase: ${user.name} (${user.userType})');
      return user;
    } catch (e) {
      print('Ошибка создания пользователя в Supabase: $e');
      rethrow;
    }
  }

  /// Получает пользователя по ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null && response is Map<String, dynamic>) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      print('Ошибка получения пользователя: $e');
      return null;
    }
  }

  /// Обновляет пользователя
  Future<void> updateUser(UserModel user) async {
    try {
      final userMap = user.toMap();
      userMap['updated_at'] = DateTime.now().toIso8601String();
      
      await _client
          .from('users')
          .update(userMap)
          .eq('id', user.id);

      // Обновляем в соответствующей ролевой таблице
      if (user.userType == 'specialist') {
        await _client
            .from('specialists')
            .update({
          'name': user.name,
          'email': user.email,
          'category': user.category,
          'description': user.description,
          'price_per_hour': user.pricePerHour,
          'avatar': user.avatar,
          'updated_at': DateTime.now().toIso8601String(),
        })
            .eq('user_id', user.id);
      } else {
        await _client
            .from('clients')
            .update({
          'name': user.name,
          'email': user.email,
          'avatar': user.avatar,
          'updated_at': DateTime.now().toIso8601String(),
        })
            .eq('user_id', user.id);
      }

      print('Пользователь обновлен: ${user.name}');
    } catch (e) {
      print('Ошибка обновления пользователя: $e');
      rethrow;
    }
  }

  /// Получает всех специалистов
  Future<List<UserModel>> getSpecialists() async {
    try {
      final response = await _client
          .from('specialists')
          .select('*, users(*)')
          .eq('is_active', true)
          .order('rating', ascending: false);

      final specialists = <UserModel>[];
      if (response is List) {
        for (final item in response) {
          if (item is Map<String, dynamic>) {
            final userData = item['users'];
            if (userData is Map<String, dynamic>) {
              specialists.add(UserModel.fromMap(userData));
            } else if (item.containsKey('user_id')) {
              final user = await getUserById(item['user_id'] as String);
              if (user != null) {
                specialists.add(user);
              }
            }
          }
        }
      }
      return specialists;
    } catch (e) {
      print('Ошибка получения специалистов: $e');
      return [];
    }
  }

  /// Получает специалистов по категории
  Future<List<UserModel>> getSpecialistsByCategory(String category) async {
    try {
      final response = await _client
          .from('specialists')
          .select('*, users(*)')
          .eq('category', category)
          .eq('is_active', true)
          .order('rating', ascending: false);

      final specialists = <UserModel>[];
      if (response is List) {
        for (final item in response) {
          if (item is Map<String, dynamic>) {
            final userData = item['users'];
            if (userData is Map<String, dynamic>) {
              specialists.add(UserModel.fromMap(userData));
            } else if (item.containsKey('user_id')) {
              final user = await getUserById(item['user_id'] as String);
              if (user != null) {
                specialists.add(user);
              }
            }
          }
        }
      }
      return specialists;
    } catch (e) {
      print('Ошибка получения специалистов по категории: $e');
      return [];
    }
  }

  /// Получает категории специалистов
  Future<List<String>> getSpecialistCategories() async {
    try {
      final response = await _client
          .from('specialists')
          .select('category')
          .eq('is_active', true);

      final categories = <String>{};
      if (response is List) {
        for (final item in response) {
          if (item is Map<String, dynamic> && item['category'] != null) {
            categories.add(item['category'] as String);
          }
        }
      }
      return categories.toList()..sort();
    } catch (e) {
      print('Ошибка получения категорий: $e');
      return [];
    }
  }

  /// Создает заказ
  Future<void> createOrder({
    required String clientId,
    required String specialistId,
    required String category,
    required String description,
    required double price,
    required DateTime scheduledDate,
    String? address,
  }) async {
    try {
      await _client
          .from('orders')
          .insert({
        'client_id': clientId,
        'specialist_id': specialistId,
        'category': category,
        'description': description,
        'price': price,
        'address': address,
        'status': 'pending', // pending, accepted, in_progress, completed, cancelled
        'scheduled_date': scheduledDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('Заказ создан');
    } catch (e) {
      print('Ошибка создания заказа: $e');
      rethrow;
    }
  }

  /// Получает заказы пользователя
  Future<List<Map<String, dynamic>>> getUserOrders(String userId, String userType) async {
    try {
      final field = userType == 'client' ? 'client_id' : 'specialist_id';
      final response = await _client
          .from('orders')
          .select()
          .eq(field, userId)
          .order('created_at', ascending: false);

      if (response is List) {
        return response.map((item) => item as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Ошибка получения заказов: $e');
      return [];
    }
  }

  /// Удаляет пользователя
  Future<void> deleteUser(String userId) async {
    try {
      // Удаляем из основной таблицы
      await _client
          .from('users')
          .delete()
          .eq('id', userId);

      // Удаляем из ролевых таблиц
      await _client
          .from('specialists')
          .delete()
          .eq('user_id', userId);

      await _client
          .from('clients')
          .delete()
          .eq('user_id', userId);

      print('Пользователь удален: $userId');
    } catch (e) {
      print('Ошибка удаления пользователя: $e');
      rethrow;
    }
  }

  /// Подписка на изменения в реальном времени (Realtime)
  RealtimeChannel subscribeToOrders(String userId, Function(Map<String, dynamic>) onUpdate) {
    return _client
        .channel('orders_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'client_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onUpdate(payload.newRecord as Map<String, dynamic>);
            }
          },
        )
        .subscribe();
  }
}

