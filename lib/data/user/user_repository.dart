import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// User discovery must hit the live server — offline cache can keep deleted
  /// profiles visible after the Firestore console is cleared.
  static const _liveServer = GetOptions(source: Source.server);

  /// Excludes seeded/test profiles from search and lookups.
  bool _shouldIncludeUser(Map<String, dynamic> data) {
    if (data['isTest'] == true) return false;
    final email = (data['email'] as String?)?.trim().toLowerCase() ?? '';
    if (email.endsWith('@example.com') || email.endsWith('@test.com')) {
      return false;
    }
    return true;
  }

  UserModel _userFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromJson({...doc.data(), 'uid': doc.id});
  }

  UserModel? _userFromDocIfAllowed(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (!_shouldIncludeUser(data)) return null;
    return _userFromDoc(doc);
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc =
        await _firestore.collection('users').doc(uid).get(_liveServer);
    if (!doc.exists) return null;
    final data = doc.data()!;
    if (!_shouldIncludeUser(data)) return null;
    return UserModel.fromJson({...data, 'uid': doc.id});
  }

  Future<UserModel?> findUserByEmail(String email) async {
    final parsedEmail = email.trim().toLowerCase();
    if (parsedEmail.isEmpty || !parsedEmail.contains('@')) return null;

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: parsedEmail)
        .limit(1)
        .get(_liveServer);

    if (snapshot.docs.isEmpty) return null;
    return _userFromDocIfAllowed(snapshot.docs.first);
  }

  Future<List<UserModel>> _prefixQueryOnField(
    String field,
    String parsedName, {
    int limit = 10,
  }) async {
    final end = '$parsedName\uf8ff';
    final snapshot = await _firestore
        .collection('users')
        .where(field, isGreaterThanOrEqualTo: parsedName)
        .where(field, isLessThan: end)
        .limit(limit)
        .get(_liveServer);

    return snapshot.docs
        .map(_userFromDocIfAllowed)
        .whereType<UserModel>()
        .toList();
  }

  /// Prefix match on [username], falling back to [nickname] when empty.
  Future<List<UserModel>> searchUsersByUsernamePrefix(
    String query, {
    int limit = 10,
  }) async {
    final parsedName = query.trim();
    if (parsedName.isEmpty) return [];

    final byUsername =
        await _prefixQueryOnField('username', parsedName, limit: limit);
    final byNickname = byUsername.isEmpty
        ? await _prefixQueryOnField('nickname', parsedName, limit: limit)
        : <UserModel>[];

    final merged = <String, UserModel>{};
    for (final user in [...byUsername, ...byNickname]) {
      merged[user.uid] = user;
    }

    final results = merged.values.toList()
      ..sort(
        (a, b) =>
            a.username.toLowerCase().compareTo(b.username.toLowerCase()),
      );
    return results.length > limit ? results.sublist(0, limit) : results;
  }

  /// Email exact match if [query] contains `@`, otherwise username prefix search.
  Future<List<UserModel>> searchUsers(
    String query, {
    int limit = 10,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    if (trimmed.contains('@')) {
      final user = await findUserByEmail(trimmed);
      return user == null ? [] : [user];
    }

    return searchUsersByUsernamePrefix(trimmed, limit: limit);
  }
}
