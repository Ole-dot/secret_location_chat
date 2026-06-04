import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/geo_message_model.dart';

class GeoMessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'geo_messages';

  /// Поток живых сообщений (кэш + офлайн, с метаданными pending).
  Stream<List<GeoMessage>> watchMessages() {
    final now = Timestamp.fromDate(DateTime.now());
    return _db
        .collection(_col)
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .limit(200)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs
            .map(GeoMessage.fromSnapshot)
            .where((m) => m.isAlive)
            .toList());
  }

  /// Отправить гео-сообщение. Офлайн: пишется в локальный кэш и уходит в очередь.
  Future<DocumentReference<Map<String, dynamic>>> sendMessage({
    required String authorUid,
    required String authorName,
    required bool isAnonymous,
    required String text,
    required double latitude,
    required double longitude,
    required Duration ttl,
  }) async {
    final now = DateTime.now();
    final displayName = isAnonymous ? _hashNick(authorUid) : authorName;

    return _db.collection(_col).add({
      'authorUid': authorUid,
      'authorName': displayName,
      'isAnonymous': isAnonymous,
      'text': text,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(ttl)),
      'replyCount': 0,
    });
  }

  Stream<List<GeoMessage>> watchReplies(String parentId) {
    return _db
        .collection(_col)
        .doc(parentId)
        .collection('replies')
        .orderBy('createdAt')
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(GeoMessage.fromSnapshot).toList());
  }

  Future<void> sendReply({
    required String parentId,
    required String authorUid,
    required String authorName,
    required bool isAnonymous,
    required String text,
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final displayName = isAnonymous ? _hashNick(authorUid) : authorName;

    final parentRef = _db.collection(_col).doc(parentId);
    final batch = _db.batch();

    batch.set(parentRef.collection('replies').doc(), {
      'authorUid': authorUid,
      'authorName': displayName,
      'isAnonymous': isAnonymous,
      'text': text,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 24))),
      'replyCount': 0,
    });

    batch.update(parentRef, {'replyCount': FieldValue.increment(1)});
    await batch.commit();
  }

  String _hashNick(String uid) {
    final code = uid.hashCode.abs() % 0xFFFF;
    return 'Shadow_${code.toRadixString(16).toUpperCase().padLeft(4, '0')}';
  }
}
