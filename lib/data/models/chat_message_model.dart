import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/core/constants/message_ttl.dart';
import 'package:secret_location_chat/data/models/ephemeral_message.dart';

class ChatMessage with EphemeralMessage {
  final String id;
  final String text;
  final String userId;
  final String nickname;
  final String avatar;
  final DateTime? timestamp;
  final DateTime expiresAt;
  final bool isPendingSync;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.nickname,
    required this.avatar,
    required this.expiresAt,
    this.timestamp,
    this.isPendingSync = false,
  });

  double get ttlProgress {
    final created = timestamp;
    if (created == null) return isAlive ? 1.0 : 0.0;
    final total = expiresAt.difference(created).inSeconds;
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (total <= 0) return isAlive ? 1.0 : 0.0;
    return (remaining / total).clamp(0.0, 1.0);
  }

  factory ChatMessage.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final ts = data['timestamp'];
    final created = ts is Timestamp ? ts.toDate() : null;
    final exp = data['expiresAt'];
    return ChatMessage(
      id: doc.id,
      text: data['text'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      nickname: data['nickname'] as String? ?? 'User',
      avatar: data['avatar'] as String? ?? 'lev.png',
      timestamp: created,
      expiresAt: exp is Timestamp
          ? exp.toDate()
          : (created ?? DateTime.now()).add(kDefaultGeoMessageTtl),
      isPendingSync: doc.metadata.hasPendingWrites,
    );
  }

  static DateTime expiresAtFromGeoData(Map<String, dynamic> data) {
    final exp = data['expiresAt'];
    if (exp is Timestamp) return exp.toDate();
    final created = data['createdAt'];
    final createdAt =
        created is Timestamp ? created.toDate() : DateTime.now();
    return createdAt.add(kDefaultGeoMessageTtl);
  }
}
