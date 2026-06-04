import 'package:cloud_firestore/cloud_firestore.dart';

enum UserLogType { mapMessage, reply }

class UserLogEvent {
  final String id;
  final String text;
  final String authorName;
  final DateTime? timestamp;
  final bool isPendingSync;
  final UserLogType type;

  const UserLogEvent({
    required this.id,
    required this.text,
    required this.authorName,
    required this.timestamp,
    required this.isPendingSync,
    required this.type,
  });

  factory UserLogEvent.fromGeoMessage(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['createdAt'];
    return UserLogEvent(
      id: doc.id,
      text: data['text'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'User',
      timestamp: ts is Timestamp ? ts.toDate() : null,
      isPendingSync: doc.metadata.hasPendingWrites,
      type: UserLogType.mapMessage,
    );
  }

  factory UserLogEvent.fromReply(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['createdAt'];
    return UserLogEvent(
      id: doc.id,
      text: data['text'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'User',
      timestamp: ts is Timestamp ? ts.toDate() : null,
      isPendingSync: doc.metadata.hasPendingWrites,
      type: UserLogType.reply,
    );
  }
}
