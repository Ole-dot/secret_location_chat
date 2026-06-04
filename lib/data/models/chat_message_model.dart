import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String userId;
  final String nickname;
  final String avatar;
  final DateTime? timestamp;
  final bool isPendingSync;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.userId,
    required this.nickname,
    required this.avatar,
    this.timestamp,
    this.isPendingSync = false,
  });

  factory ChatMessage.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final ts = data['timestamp'];
    return ChatMessage(
      id: doc.id,
      text: data['text'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      nickname: data['nickname'] as String? ?? 'User',
      avatar: data['avatar'] as String? ?? 'lev.png',
      timestamp: ts is Timestamp ? ts.toDate() : null,
      isPendingSync: doc.metadata.hasPendingWrites,
    );
  }
}
