import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/core/auth/firebase_auth_language.dart';
import 'package:secret_location_chat/core/utils/cyberpunk_nickname.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Текущий пользователь
  User? get currentUser => _auth.currentUser;

  /// Поток состояния авторизации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Проверка авторизован ли пользователь
  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  /// Вход по email + пароль
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return null;
    return _fetchUserModel(credential.user!.uid);
  }

  /// Регистрация
  Future<UserModel?> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) return null;

      final nickname = username.trim().isEmpty
          ? generateCyberpunkNickname()
          : username.trim();

      final user = UserModel(
        uid: credential.user!.uid,
        email: email.trim().toLowerCase(),
        username: nickname,
        isAnonymousMode: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set({
        ...user.toJson(),
        'nickname': nickname,
        'avatar': 'lev.png',
        'stonesBalance': 0,
        'stonesLifetimeEarned': 0,
        'stonesLifetimeSpent': 0,
        'stonesVersion': 0,
        'stonesUpdatedAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Сброс пароля — письмо со ссылкой на email (язык письма через Firebase).
  ///
  /// [languageCode] — необязательно: `ru` или `kk`. Если null — из локали устройства.
  Future<void> sendPasswordResetEmail(
    String email, {
    String? languageCode,
  }) async {
    final lang = resolveFirebaseAuthLanguageCode(languageCode);
    await _auth.setLanguageCode(lang);
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Выход
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> fetchUserProfile(String uid) => _fetchUserModel(uid);

  Future<void> updateUserProfile(
    String uid, {
    String? nickname,
    String? avatar,
  }) async {
    final updates = <String, dynamic>{};
    if (nickname != null) {
      updates['nickname'] = nickname;
      updates['username'] = nickname;
    }
    if (avatar != null) updates['avatar'] = avatar;
    if (updates.isEmpty) return;
    await _firestore.collection('users').doc(uid).update(updates);
  }

  Future<UserModel?> _fetchUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }
}
