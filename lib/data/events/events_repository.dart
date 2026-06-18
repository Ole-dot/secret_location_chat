import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:secret_location_chat/core/localization/events_l10n.dart';
import 'package:secret_location_chat/data/models/user_log_event.dart';

class MyLogsPayload {
  final List<UserLogEvent> logs;
  final String? warning;
  final String? error;

  const MyLogsPayload({
    required this.logs,
    this.warning,
    this.error,
  });
}

class _QueryPayload {
  final List<UserLogEvent> logs;
  final String? warning;
  final String? error;

  const _QueryPayload({
    required this.logs,
    this.warning,
    this.error,
  });
}

class EventsRepository {
  final FirebaseFirestore _db;

  EventsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  void _logFirestoreError(String operation, Object error, [StackTrace? st]) {
    debugPrint('FIREBASE ERROR: $error');
    if (error is FirebaseException) {
      final line =
          '[EventsRepository] $operation | FirebaseException '
          'plugin=${error.plugin} code=${error.code} message=${error.message}';
      developer.log(line, name: 'EventsRepository', error: error, stackTrace: st);
      debugPrint(line);
    } else {
      developer.log(
        '[EventsRepository] $operation | $error',
        name: 'EventsRepository',
        error: error,
        stackTrace: st,
      );
      debugPrint('[EventsRepository] $operation | $error');
    }
  }

  String formatUiError(Object error) {
    if (error is FirebaseException) {
      return formatEventsNetworkError(
        error.code,
        error.message?.trim() ?? '',
      );
    }
    return formatEventsNetworkError('unknown', error.toString());
  }

  Query<Map<String, dynamic>> _aliveGeoMessagesQuery() {
    final now = Timestamp.fromDate(DateTime.now());
    // COMPOSITE INDEX (optional): expiresAt ASC + createdAt DESC — see firestore.indexes.json.
    // Results are sorted client-side by createdAt when only expiresAt is used.
    return _db
        .collection('geo_messages')
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt');
  }

  Query<Map<String, dynamic>> _aliveChatMessagesGlobalQuery() {
    final now = Timestamp.fromDate(DateTime.now());
    return _db
        .collectionGroup('chat_messages')
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt');
  }

  List<UserLogEvent> _mergeGlobalEvents(
    List<UserLogEvent> posts,
    List<UserLogEvent> threadMessages,
  ) {
    final merged = <UserLogEvent>[...posts, ...threadMessages]
      ..sort((a, b) {
        final left = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
    if (merged.length > 100) {
      return merged.sublist(0, 100);
    }
    return merged;
  }

  /// Live global feed: geo posts + all replies (expiresAt > now).
  Future<List<UserLogEvent>> fetchGlobalEvents() async {
    debugPrint('[EventsRepository] >>> fetchGlobalEvents START');
    try {
      final snaps = await Future.wait([
        _aliveGeoMessagesQuery().limit(200).get(),
        _aliveChatMessagesGlobalQuery().limit(200).get(),
      ]);
      final postsSnap = snaps[0];
      final threadSnap = snaps[1];
      debugPrint(
        '[EventsRepository] fetchGlobalEvents ok | '
        'posts=${postsSnap.docs.length} threads=${threadSnap.docs.length}',
      );
      final posts = postsSnap.docs.map(UserLogEvent.fromGeoMessage).toList();
      final threadMessages =
          threadSnap.docs.map(UserLogEvent.fromChatMessage).toList();
      return _mergeGlobalEvents(posts, threadMessages);
    } on FirebaseException catch (error, st) {
      debugPrint('FIREBASE ERROR: $error');
      debugPrint('[EventsRepository] CATCH REACHED: fetchGlobalEvents');
      _logFirestoreError('fetchGlobalEvents', error, st);
      rethrow;
    } catch (error, st) {
      debugPrint('FIREBASE ERROR: $error');
      debugPrint('[EventsRepository] CATCH REACHED: fetchGlobalEvents');
      _logFirestoreError('fetchGlobalEvents', error, st);
      rethrow;
    }
  }

  /// Live global feed stream: geo posts + all replies (expiresAt > now).
  Stream<List<UserLogEvent>> watchGlobalEvents() {
    debugPrint('[EventsRepository] >>> watchGlobalEvents subscribed');
    final controller = StreamController<List<UserLogEvent>>();
    List<UserLogEvent> latestPosts = const [];
    List<UserLogEvent> latestThreadMessages = const [];

    void publish() {
      if (controller.isClosed) return;
      try {
        controller.add(_mergeGlobalEvents(latestPosts, latestThreadMessages));
      } on FirebaseException catch (error, st) {
        debugPrint('FIREBASE ERROR: $error');
        debugPrint('[EventsRepository] CATCH REACHED: watchGlobalEvents/merge');
        _logFirestoreError('watchGlobalEvents/merge', error, st);
        controller.addError(error, st);
      } catch (error, st) {
        debugPrint('FIREBASE ERROR: $error');
        debugPrint('[EventsRepository] CATCH REACHED: watchGlobalEvents/merge');
        _logFirestoreError('watchGlobalEvents/merge', error, st);
        controller.addError(error, st);
      }
    }

    final postsSub = _aliveGeoMessagesQuery()
        .limit(200)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (snap) {
        latestPosts = snap.docs.map(UserLogEvent.fromGeoMessage).toList();
        publish();
      },
      onError: (Object error, StackTrace st) {
        debugPrint('FIREBASE ERROR: $error');
        debugPrint('[EventsRepository] CATCH REACHED: watchGlobalEvents/posts');
        _logFirestoreError('watchGlobalEvents/posts', error, st);
        controller.addError(error, st);
      },
    );

    final threadSub = _aliveChatMessagesGlobalQuery()
        .limit(200)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (snap) {
        latestThreadMessages =
            snap.docs.map(UserLogEvent.fromChatMessage).toList();
        publish();
      },
      onError: (Object error, StackTrace st) {
        debugPrint('FIREBASE ERROR: $error');
        debugPrint('[EventsRepository] CATCH REACHED: watchGlobalEvents/chat_messages');
        _logFirestoreError('watchGlobalEvents/chat_messages', error, st);
        controller.addError(error, st);
      },
    );

    controller.onCancel = () {
      postsSub.cancel();
      threadSub.cancel();
    };

    return controller.stream;
  }

  Future<MyLogsPayload> fetchMyLogs(String userId) async {
    debugPrint('[EventsRepository] >>> fetchMyLogs START uid=$userId');

    late final List<_QueryPayload> results;
    try {
      results = await Future.wait<_QueryPayload>([
        _safeMessagesQuery(userId),
        _safeChatMessagesQuery(userId),
      ]);
    } on FirebaseException catch (error, st) {
      debugPrint('FIREBASE ERROR: $error');
      debugPrint('[EventsRepository] CATCH REACHED: fetchMyLogs');
      _logFirestoreError('fetchMyLogs', error, st);
      return MyLogsPayload(
        logs: const [],
        error: formatUiError(error),
      );
    } catch (error, st) {
      debugPrint('FIREBASE ERROR: $error');
      debugPrint('[EventsRepository] CATCH REACHED: fetchMyLogs');
      _logFirestoreError('fetchMyLogs', error, st);
      return MyLogsPayload(
        logs: const [],
        error: formatUiError(error),
      );
    }

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

    final errors = results
        .map((entry) => entry.error)
        .whereType<String>()
        .toList(growable: false);

    debugPrint(
      '[EventsRepository] fetchMyLogs done | '
      'count=${merged.length} warnings=${warnings.length} errors=${errors.length}',
    );

    final String? errorMessage;
    if (errors.isEmpty) {
      errorMessage = null;
    } else if (merged.isEmpty) {
      errorMessage = errors.join('\n');
    } else {
      errorMessage = null;
    }

    return MyLogsPayload(
      logs: merged,
      warning: warnings.isEmpty ? null : warnings.join(' | '),
      error: errorMessage,
    );
  }

  Future<_QueryPayload> _safeMessagesQuery(String userId) async {
    debugPrint('[EventsRepository] >>> _safeMessagesQuery START uid=$userId');
    try {
      // COMPOSITE INDEX: authorUid + expiresAt — see firestore.indexes.json.
      final now = Timestamp.fromDate(DateTime.now());
      final snap = await _db
          .collection('geo_messages')
          .where('authorUid', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .limit(200)
          .get();
      debugPrint(
        '[EventsRepository] geo_messages query ok | docs=${snap.docs.length}',
      );
      final logs = snap.docs.map(UserLogEvent.fromGeoMessage).toList()
        ..sort((a, b) {
          final left = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
          final right = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
          return right.compareTo(left);
        });
      return _QueryPayload(
        logs: logs.length > 100 ? logs.sublist(0, 100) : logs,
        warning: null,
        error: null,
      );
    } on FirebaseException catch (error, st) {
      debugPrint('FIREBASE ERROR: $error');
      debugPrint('[EventsRepository] CATCH REACHED: _safeMessagesQuery');
      _logFirestoreError(
        'geo_messages where(authorUid)+where(expiresAt)+orderBy(expiresAt)',
        error,
        st,
      );
      final description = formatUiError(error);
      return _QueryPayload(
        logs: const [],
        warning: description,
        error: description,
      );
    } catch (error, st) {
      debugPrint('FIREBASE ERROR: $error');
      debugPrint('[EventsRepository] CATCH REACHED: _safeMessagesQuery');
      _logFirestoreError(
        'geo_messages where(authorUid)+where(expiresAt)+orderBy(expiresAt)',
        error,
        st,
      );
      final description = formatUiError(error);
      return _QueryPayload(
        logs: const [],
        warning: description,
        error: description,
      );
    }
  }

  Future<_QueryPayload> _safeChatMessagesQuery(String userId) async {
    debugPrint('[EventsRepository] >>> _safeChatMessagesQuery START uid=$userId');
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final snap = await _db
          .collectionGroup('chat_messages')
          .where('authorUid', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .limit(200)
          .get();
      debugPrint(
        '[EventsRepository] collectionGroup(chat_messages) query ok | docs=${snap.docs.length}',
      );
      final logs = snap.docs.map(UserLogEvent.fromChatMessage).toList()
        ..sort((a, b) {
          final left = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
          final right = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
          return right.compareTo(left);
        });
      return _QueryPayload(
        logs: logs.length > 100 ? logs.sublist(0, 100) : logs,
        warning: null,
        error: null,
      );
    } on FirebaseException catch (error, st) {
      debugPrint('FIREBASE ERROR: $error');
      debugPrint('[EventsRepository] CATCH REACHED: _safeChatMessagesQuery');
      _logFirestoreError(
        'collectionGroup(chat_messages) where(authorUid)+where(expiresAt)+orderBy(expiresAt)',
        error,
        st,
      );
      final description = formatUiError(error);
      return _QueryPayload(
        logs: const [],
        warning: description,
        error: description,
      );
    } catch (error, st) {
      debugPrint('FIREBASE ERROR: $error');
      debugPrint('[EventsRepository] CATCH REACHED: _safeChatMessagesQuery');
      _logFirestoreError(
        'collectionGroup(chat_messages) where(authorUid)+where(expiresAt)+orderBy(expiresAt)',
        error,
        st,
      );
      final description = formatUiError(error);
      return _QueryPayload(
        logs: const [],
        warning: description,
        error: description,
      );
    }
  }
}
