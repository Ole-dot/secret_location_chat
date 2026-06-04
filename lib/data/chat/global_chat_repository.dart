import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/chat_message_model.dart';

class GlobalChatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'messages';

  Stream<List<ChatMessage>> watchMessages() {
    return _db
        .collection(_col)
        .orderBy('timestamp', descending: false)
        .limit(200)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(ChatMessage.fromSnapshot).toList());
  }

  Future<void> sendMessage({
    required String text,
    required String userId,
    required String nickname,
    required String avatar,
  }) async {
    await _db.collection(_col).add({
      'text': text.trim(),
      'userId': userId,
      'nickname': nickname,
      'avatar': avatar,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
