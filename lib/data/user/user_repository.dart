import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Поиск пользователя по точному совпадению email.
  /// Возвращает null, если пользователь не найден.
  Future<UserModel?> findUserByEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: normalized)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return UserModel.fromJson(snapshot.docs.first.data());
  }
}
