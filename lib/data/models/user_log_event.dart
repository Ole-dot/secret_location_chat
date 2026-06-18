import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/chat_message_model.dart';
import 'package:secret_location_chat/data/models/ephemeral_message.dart';

enum UserLogType { mapMessage, reply }

class UserLogEvent with EphemeralMessage {
  final String id;
  final String text;
  final String authorName;
  final DateTime? timestamp;
  final DateTime expiresAt;
  final double? latitude;
  final double? longitude;
  final bool isPendingSync;
  final UserLogType type;

  const UserLogEvent({
    required this.id,
    required this.text,
    required this.authorName,
    required this.timestamp,
    required this.expiresAt,
    this.latitude,
    this.longitude,
    required this.isPendingSync,
    required this.type,
  });

  bool get hasLocation => latitude != null && longitude != null;

  /// Parent geo_messages document id (for map marker / message card).
  String? get geoMessageDocumentId {
    final parts = id.split('/');
    final idx = parts.indexOf('geo_messages');
    if (idx < 0 || idx + 1 >= parts.length) return null;
    return parts[idx + 1];
  }

  double get ttlProgress {
    final created = timestamp;
    if (created == null) return isAlive ? 1.0 : 0.0;
    final total = expiresAt.difference(created).inSeconds;
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (total <= 0) return isAlive ? 1.0 : 0.0;
    return (remaining / total).clamp(0.0, 1.0);
  }

  factory UserLogEvent.fromGeoMessage(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['createdAt'];
    return UserLogEvent(
      id: doc.reference.path,
      text: data['text'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'User',
      timestamp: ts is Timestamp ? ts.toDate() : null,
      expiresAt: ChatMessage.expiresAtFromGeoData(data),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      isPendingSync: doc.metadata.hasPendingWrites,
      type: UserLogType.mapMessage,
    );
  }

  factory UserLogEvent.fromReply(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) =>
      UserLogEvent.fromChatMessage(doc);

  factory UserLogEvent.fromChatMessage(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final ts = data['createdAt'];
    return UserLogEvent(
      id: doc.reference.path,
      text: data['text'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'User',
      timestamp: ts is Timestamp ? ts.toDate() : null,
      expiresAt: ChatMessage.expiresAtFromGeoData(data),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      isPendingSync: doc.metadata.hasPendingWrites,
      type: UserLogType.reply,
    );
  }
}
