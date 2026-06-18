import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/geo_message_model.dart';
import 'package:secret_location_chat/data/models/map_thread_message.dart';

class GeoMessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'geo_messages';
  static const String _chatSub = 'chat_messages';

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

  Stream<GeoMessage?> watchMessage(String messageId) {
    return _db
        .collection(_col)
        .doc(messageId)
        .snapshots(includeMetadataChanges: true)
        .map((doc) {
      if (!doc.exists) return null;
      return GeoMessage.fromSnapshot(doc);
    });
  }

  Future<GeoMessage?> getMessage(String messageId) async {
    final doc = await _db.collection(_col).doc(messageId).get();
    if (!doc.exists) return null;
    return GeoMessage.fromSnapshot(doc);
  }

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

  Stream<List<MapThreadMessage>> watchChatMessages(String parentId) {
    final now = Timestamp.fromDate(DateTime.now());
    return _db
        .collection(_col)
        .doc(parentId)
        .collection(_chatSub)
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .snapshots(includeMetadataChanges: true)
        .map((snap) {
      final messages = snap.docs
          .map(MapThreadMessage.fromSnapshot)
          .where((message) => message.isAlive)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return messages;
    });
  }

  Future<void> sendChatMessage({
    required String parentId,
    required String authorUid,
    required String authorName,
    required bool isAnonymous,
    required String text,
  }) async {
    final parentRef = _db.collection(_col).doc(parentId);
    final parentSnap = await parentRef.get();
    if (!parentSnap.exists) {
      throw StateError('PARENT_NOT_FOUND');
    }

    final parentData = parentSnap.data()!;
    final parentExpiresAt = parentData['expiresAt'] as Timestamp?;
    if (parentExpiresAt == null ||
        parentExpiresAt.toDate().isBefore(DateTime.now())) {
      throw StateError('PARENT_EXPIRED');
    }

    final now = DateTime.now();
    final displayName = isAnonymous ? _hashNick(authorUid) : authorName;
    final batch = _db.batch();

    batch.set(parentRef.collection(_chatSub).doc(), {
      'authorUid': authorUid,
      'authorName': displayName,
      'isAnonymous': isAnonymous,
      'text': text,
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': parentExpiresAt,
    });

    batch.update(parentRef, {'replyCount': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> deleteMessageWithThread({
    required String messageId,
    required String authorUid,
  }) async {
    final parentRef = _db.collection(_col).doc(messageId);
    final parentSnap = await parentRef.get();
    if (!parentSnap.exists) return;
    if (parentSnap.data()?['authorUid'] != authorUid) {
      throw StateError('NOT_AUTHOR');
    }

    final chatCol = parentRef.collection(_chatSub);
    while (true) {
      final snap = await chatCol.limit(100).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    await parentRef.delete();
  }

  String _hashNick(String uid) {
    final code = uid.hashCode.abs() % 0xFFFF;
    return 'Shadow_${code.toRadixString(16).toUpperCase().padLeft(4, '0')}';
  }
}
