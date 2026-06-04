import 'package:cloud_firestore/cloud_firestore.dart';

/// Геосообщение на карте с TTL (time-to-live)
class GeoMessage {
  final String id;
  final String authorUid;
  final String authorName;   // ник или '???' если анонимно
  final bool isAnonymous;
  final String text;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final DateTime expiresAt;  // TTL — когда сообщение исчезнет
  final int replyCount;
  /// Локальная запись ещё не подтверждена сервером (офлайн-очередь).
  final bool isPendingSync;

  const GeoMessage({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.isAnonymous,
    required this.text,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.expiresAt,
    this.replyCount = 0,
    this.isPendingSync = false,
  });

  /// Осталось ли сообщение живым?
  bool get isAlive => DateTime.now().isBefore(expiresAt);

  /// Процент оставшегося времени жизни (0.0 — 1.0)
  double get ttlProgress {
    final total = expiresAt.difference(createdAt).inSeconds;
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    if (total <= 0) return 0;
    return (remaining / total).clamp(0.0, 1.0);
  }

  factory GeoMessage.fromJson(
    Map<String, dynamic> json,
    String id, {
    bool isPendingSync = false,
  }) =>
      GeoMessage(
        id: id,
        authorUid: json['authorUid'] as String,
        authorName: json['authorName'] as String,
        isAnonymous: json['isAnonymous'] as bool? ?? false,
        text: json['text'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        expiresAt: (json['expiresAt'] as Timestamp).toDate(),
        replyCount: json['replyCount'] as int? ?? 0,
        isPendingSync: isPendingSync,
      );

  factory GeoMessage.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return GeoMessage.fromJson(
      data,
      doc.id,
      isPendingSync: doc.metadata.hasPendingWrites,
    );
  }

  Map<String, dynamic> toJson() => {
    'authorUid': authorUid,
    'authorName': authorName,
    'isAnonymous': isAnonymous,
    'text': text,
    'latitude': latitude,
    'longitude': longitude,
    'createdAt': Timestamp.fromDate(createdAt),
    'expiresAt': Timestamp.fromDate(expiresAt),
    'replyCount': replyCount,
  };
}
