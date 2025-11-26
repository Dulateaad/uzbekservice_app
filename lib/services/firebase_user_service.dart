import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../config/firebase_config.dart';
import '../models/user_model.dart';

class FirebaseUserService {
  static final FirebaseUserService _instance = FirebaseUserService._internal();
  factory FirebaseUserService() => _instance;
  FirebaseUserService._internal();

  final firebase_auth.FirebaseAuth _auth = FirebaseConfig.auth;
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  /// Получает текущего пользователя
  firebase_auth.User? get currentUser => _auth.currentUser;

  /// Создает пользователя в Firestore
  Future<UserModel> createUser({
    required String phoneNumber,
    required String name,
    required String userType,
    String? email,
    String? category,
    String? description,
    double? pricePerHour,
  }) async {
    try {
      final user = UserModel(
        id: _auth.currentUser?.uid ?? '',
        phoneNumber: phoneNumber,
        name: name,
        email: email,
        userType: userType,
        category: category,
        description: description,
        pricePerHour: pricePerHour,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: true,
      );

      // Сохраняем в Firestore
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap());

      print('Пользователь создан: ${user.name} (${user.userType})');
      return user;
    } catch (e) {
      print('Ошибка создания пользователя: $e');
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
      
      print('Пользователь обновлен: ${user.name}');
    } catch (e) {
      print('Ошибка обновления пользователя: $e');
      rethrow;
    }
  }

  /// Удаляет пользователя
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .delete();
      
      print('Пользователь удален: $userId');
    } catch (e) {
      print('Ошибка удаления пользователя: $e');
      rethrow;
    }
  }

  /// Получает всех специалистов
  Future<List<UserModel>> getSpecialists() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'specialist')
          .where('isVerified', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Ошибка получения специалистов: $e');
      return [];
    }
  }

  /// Получает специалистов по категории
  Future<List<UserModel>> getSpecialistsByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'specialist')
          .where('category', isEqualTo: category)
          .where('isVerified', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Ошибка получения специалистов по категории: $e');
      return [];
    }
  }

  /// Выход из системы
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Пользователь вышел из системы');
    } catch (e) {
      print('Ошибка выхода: $e');
      rethrow;
    }
  }
}
