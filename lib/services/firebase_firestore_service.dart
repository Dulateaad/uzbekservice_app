import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../config/firebase_config.dart';
import '../models/user_model.dart';

class FirebaseFirestoreService {
  static final FirebaseFirestoreService _instance = FirebaseFirestoreService._internal();
  factory FirebaseFirestoreService() => _instance;
  FirebaseFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseConfig.firestore;
  final firebase_auth.FirebaseAuth _auth = FirebaseConfig.auth;

  /// Создает пользователя в Firestore
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
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не аутентифицирован');
      }

      final user = UserModel(
        id: currentUser.uid,
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

      // Сохраняем в коллекцию users
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap());

      // Создаем подколлекцию для роли
      if (userType == 'specialist') {
        await _firestore
            .collection('specialists')
            .doc(user.id)
            .set({
          'userId': user.id,
          'phoneNumber': phoneNumber,
          'name': name,
          'email': email,
          'category': category,
          'description': description,
          'pricePerHour': pricePerHour,
          'avatar': avatar,
          'rating': 0.0,
          'totalReviews': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore
            .collection('clients')
            .doc(user.id)
            .set({
          'userId': user.id,
          'phoneNumber': phoneNumber,
          'name': name,
          'email': email,
          'avatar': avatar,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      print('Пользователь создан в Firestore: ${user.name} (${user.userType})');
      return user;
    } catch (e) {
      print('Ошибка создания пользователя в Firestore: $e');
      rethrow;
    }
  }

  /// Получает пользователя по ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
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
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toMap());

      // Обновляем в соответствующей ролевой коллекции
      if (user.userType == 'specialist') {
        await _firestore
            .collection('specialists')
            .doc(user.id)
            .update({
          'name': user.name,
          'email': user.email,
          'category': user.category,
          'description': user.description,
          'pricePerHour': user.pricePerHour,
          'avatar': user.avatar,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore
            .collection('clients')
            .doc(user.id)
            .update({
          'name': user.name,
          'email': user.email,
          'avatar': user.avatar,
          'updatedAt': FieldValue.serverTimestamp(),
        });
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
      final querySnapshot = await _firestore
          .collection('specialists')
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      final specialists = <UserModel>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final user = await getUserById(data['userId']);
        if (user != null) {
          specialists.add(user);
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
      final querySnapshot = await _firestore
          .collection('specialists')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

      final specialists = <UserModel>[];
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final user = await getUserById(data['userId']);
        if (user != null) {
          specialists.add(user);
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
      final querySnapshot = await _firestore
          .collection('specialists')
          .where('isActive', isEqualTo: true)
          .get();

      final categories = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['category'] != null) {
          categories.add(data['category']);
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
      final orderData = {
        'clientId': clientId,
        'specialistId': specialistId,
        'category': category,
        'description': description,
        'price': price,
        'address': address,
        'status': 'pending', // pending, accepted, in_progress, completed, cancelled
        'scheduledDate': Timestamp.fromDate(scheduledDate),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('orders')
          .add(orderData);

      print('Заказ создан');
    } catch (e) {
      print('Ошибка создания заказа: $e');
      rethrow;
    }
  }

  /// Получает заказы пользователя
  Future<List<Map<String, dynamic>>> getUserOrders(String userId, String userType) async {
    try {
      final field = userType == 'client' ? 'clientId' : 'specialistId';
      final querySnapshot = await _firestore
          .collection('orders')
          .where(field, isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Ошибка получения заказов: $e');
      return [];
    }
  }

  /// Удаляет пользователя
  Future<void> deleteUser(String userId) async {
    try {
      // Удаляем из основной коллекции
      await _firestore
          .collection('users')
          .doc(userId)
          .delete();

      // Удаляем из ролевых коллекций
      await _firestore
          .collection('specialists')
          .doc(userId)
          .delete();

      await _firestore
          .collection('clients')
          .doc(userId)
          .delete();

      print('Пользователь удален: $userId');
    } catch (e) {
      print('Ошибка удаления пользователя: $e');
      rethrow;
    }
  }
}
