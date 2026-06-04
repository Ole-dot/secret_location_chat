import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/events/events_repository.dart';
import 'package:secret_location_chat/data/models/chat_message_model.dart';
import 'package:secret_location_chat/data/models/user_log_event.dart';

class EventsState {
  final List<ChatMessage> globalLogs;
  final List<UserLogEvent> myLogs;
  final bool isLoading;
  final String? globalError;
  final String? myLogsError;
  final String? myLogsWarning;

  const EventsState({
    this.globalLogs = const [],
    this.myLogs = const [],
    this.isLoading = true,
    this.globalError,
    this.myLogsError,
    this.myLogsWarning,
  });

  EventsState copyWith({
    List<ChatMessage>? globalLogs,
    List<UserLogEvent>? myLogs,
    bool? isLoading,
    String? globalError,
    String? myLogsError,
    String? myLogsWarning,
    bool clearGlobalError = false,
    bool clearMyLogsError = false,
    bool clearMyLogsWarning = false,
  }) =>
      EventsState(
        globalLogs: globalLogs ?? this.globalLogs,
        myLogs: myLogs ?? this.myLogs,
        isLoading: isLoading ?? this.isLoading,
        globalError:
            clearGlobalError ? null : (globalError ?? this.globalError),
        myLogsError:
            clearMyLogsError ? null : (myLogsError ?? this.myLogsError),
        myLogsWarning: clearMyLogsWarning
            ? null
            : (myLogsWarning ?? this.myLogsWarning),
      );
}

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository _repository;
  final String _userId;

  StreamSubscription<List<ChatMessage>>? _globalSub;

  EventsCubit({
    required EventsRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(const EventsState()) {
    _start();
  }

  void _start() {
    var globalReady = false;
    var myReady = false;

    void maybeReady() {
      if (globalReady && myReady && !isClosed) {
        emit(state.copyWith(isLoading: false));
      }
    }

    _globalSub = _repository.watchGlobalEvents().listen(
      (logs) {
        if (isClosed) return;
        globalReady = true;
        emit(state.copyWith(
          globalLogs: logs,
          clearGlobalError: true,
        ));
        maybeReady();
      },
      onError: (Object err) {
        if (isClosed) return;
        globalReady = true;
        emit(state.copyWith(
          isLoading: false,
          globalError: _mapEventsError(err),
        ));
        maybeReady();
      },
    );

    _loadMyLogs().then((_) {
      if (isClosed) return;
      myReady = true;
      maybeReady();
    });
  }

  Future<void> _loadMyLogs() async {
    try {
      final payload = await _repository.fetchMyLogs(_userId);
      if (isClosed) return;
      emit(state.copyWith(
        myLogs: payload.logs,
        myLogsWarning: payload.warning,
        clearMyLogsError: true,
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        myLogsError: _mapEventsError(err),
        clearMyLogsWarning: true,
      ));
    }
  }

  String _mapEventsError(Object err) {
    if (err is FirebaseException && err.code == 'failed-precondition') {
      return 'MISSING INDEX. CHECK CONSOLE.';
    }
    final text = err.toString().toLowerCase();
    if (text.contains('failed-precondition') ||
        text.contains('requires an index') ||
        text.contains('create_composite')) {
      return 'MISSING INDEX. CHECK CONSOLE.';
    }
    return mapFirebaseError(err);
  }

  @override
  Future<void> close() {
    _globalSub?.cancel();
    return super.close();
  }
}
