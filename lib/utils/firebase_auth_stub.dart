// Заглушки для Firebase Auth типов
// Используется для совместимости с Firebase Auth

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../config/firebase_config.dart';

// Заглушка для User из Firebase Auth
class User {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;

  User({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
  });

  // Конвертация из Firebase User
  factory User.fromFirebase(firebase_auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      phoneNumber: firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
    );
  }
}

// Заглушка для FirebaseAuth
class FirebaseAuth {
  static FirebaseAuth get instance => FirebaseAuth._();
  FirebaseAuth._();

  User? get currentUser {
    final firebaseUser = FirebaseConfig.currentUser;
    if (firebaseUser == null) return null;
    return User.fromFirebase(firebaseUser);
  }

  Future<void> signOut() async {
    await FirebaseConfig.auth.signOut();
  }
}

