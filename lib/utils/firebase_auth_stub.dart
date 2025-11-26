// Заглушки для Firebase Auth типов
// Используется для совместимости при миграции на Supabase

import '../config/supabase_config.dart';

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

  // Конвертация из Supabase User
  factory User.fromSupabase(dynamic supabaseUser) {
    if (supabaseUser == null) {
      throw Exception('User is null');
    }
    return User(
      uid: supabaseUser.id ?? '',
      email: supabaseUser.email,
      phoneNumber: supabaseUser.phone,
      displayName: supabaseUser.userMetadata?['name'],
      photoURL: supabaseUser.userMetadata?['avatar'],
      emailVerified: supabaseUser.emailConfirmedAt != null,
    );
  }
}

// Заглушка для FirebaseAuth
class FirebaseAuth {
  static FirebaseAuth get instance => FirebaseAuth._();
  FirebaseAuth._();

  User? get currentUser {
    final supabaseUser = SupabaseConfig.currentUser;
    if (supabaseUser == null) return null;
    return User.fromSupabase(supabaseUser);
  }

  Future<void> signOut() async {
    await SupabaseConfig.client.auth.signOut();
  }
}

