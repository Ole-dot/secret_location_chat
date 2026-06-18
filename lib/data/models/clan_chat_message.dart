import 'package:cloud_firestore/cloud_firestore.dart';

class ClanChatMessage {
  final String id;
  final String authorUid;
  final String authorName;
  final String text;
  final DateTime? timestamp;
  final DateTime? expiresAt;

  const ClanChatMessage({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.text,
    this.timestamp,
    this.expiresAt,
  });

  bool get isAlive {
    final expiry = expiresAt;
    if (expiry == null) return true;
    return DateTime.now().isBefore(expiry);
  }

  factory ClanChatMessage.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final ts = data['timestamp'];
    final exp = data['expiresAt'];
    return ClanChatMessage(
      id: id,
      authorUid: data['authorUid'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'User',
      text: data['text'] as String? ?? '',
      timestamp: ts is Timestamp ? ts.toDate() : null,
      expiresAt: exp is Timestamp ? exp.toDate() : null,
    );
  }
}
