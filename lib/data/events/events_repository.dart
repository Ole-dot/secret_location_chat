import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/chat_message_model.dart';
import 'package:secret_location_chat/data/models/user_log_event.dart';

class MyLogsPayload {
  final List<UserLogEvent> logs;
  final String? warning;

  const MyLogsPayload({
    required this.logs,
    required this.warning,
  });
}

class _QueryPayload {
  final List<UserLogEvent> logs;
  final String? warning;

  const _QueryPayload({
    required this.logs,
    required this.warning,
  });
}

class EventsRepository {
  final FirebaseFirestore _db;

  EventsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<ChatMessage>> watchGlobalEvents() {
    return _db
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(ChatMessage.fromSnapshot).toList());
  }

  Stream<List<ChatMessage>> watchMyLogs(String userId) {
    return _db
        .collection('messages')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(ChatMessage.fromSnapshot).toList());
  }

  Future<MyLogsPayload> fetchMyLogs(String userId) async {
    final results = await Future.wait<_QueryPayload>([
      _safeMessagesQuery(userId),
      _safeRepliesQuery(userId),
    ]);

    final merged = <UserLogEvent>[
      ...results[0].logs,
      ...results[1].logs,
    ]..sort((a, b) {
        final left = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });

    final warnings = results
        .map((entry) => entry.warning)
        .whereType<String>()
        .toList(growable: false);

    return MyLogsPayload(
      logs: merged,
      warning: warnings.isEmpty ? null : warnings.join(' | '),
    );
  }

  Future<_QueryPayload> _safeMessagesQuery(String userId) async {
    try {
      final snap = await _db
          .collection('geo_messages')
          .where('authorUid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return _QueryPayload(
        logs: snap.docs.map(UserLogEvent.fromGeoMessage).toList(),
        warning: null,
      );
    } catch (_) {
      return const _QueryPayload(
        logs: [],
        warning: 'FRAGMENT WARNING: MAIN MAP LOGS DEGRADED',
      );
    }
  }

  Future<_QueryPayload> _safeRepliesQuery(String userId) async {
    try {
      final snap = await _db
          .collectionGroup('replies')
          .where('authorUid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return _QueryPayload(
        logs: snap.docs.map(UserLogEvent.fromReply).toList(),
        warning: null,
      );
    } catch (_) {
      return const _QueryPayload(
        logs: [],
        warning: 'FRAGMENT WARNING: REPLY LOGS DEGRADED',
      );
    }
  }
}
