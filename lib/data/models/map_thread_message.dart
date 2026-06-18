import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/ephemeral_message.dart';

class MapThreadMessage with EphemeralMessage {
  final String id;
  final String authorUid;
  final String authorName;
  final bool isAnonymous;
  final String text;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isPendingSync;

  const MapThreadMessage({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.isAnonymous,
    required this.text,
    required this.createdAt,
    required this.expiresAt,
    this.isPendingSync = false,
  });

  factory MapThreadMessage.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MapThreadMessage(
      id: doc.id,
      authorUid: data['authorUid'] as String,
      authorName: data['authorName'] as String,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      text: data['text'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isPendingSync: doc.metadata.hasPendingWrites,
    );
  }
}
