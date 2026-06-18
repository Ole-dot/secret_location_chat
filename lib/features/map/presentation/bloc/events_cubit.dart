import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/localization/events_l10n.dart';
import 'package:secret_location_chat/data/events/events_repository.dart';
import 'package:secret_location_chat/data/models/user_log_event.dart';

class EventsState {
  final List<UserLogEvent> globalLogs;
  final List<UserLogEvent> myLogs;
  final Set<String> burnedGlobalIds;
  final Set<String> burnedMyLogIds;
  final bool globalLoading;
  final bool myLogsLoading;
  final String? globalError;
  final String? myLogsError;
  final String? myLogsWarning;

  const EventsState({
    this.globalLogs = const [],
    this.myLogs = const [],
    this.burnedGlobalIds = const {},
    this.burnedMyLogIds = const {},
    this.globalLoading = true,
    this.myLogsLoading = true,
    this.globalError,
    this.myLogsError,
    this.myLogsWarning,
  });

  bool get isLoading => globalLoading || myLogsLoading;

  List<UserLogEvent> get visibleGlobalLogs => globalLogs
      .where(
        (event) => event.isAlive && !burnedGlobalIds.contains(event.id),
      )
      .toList(growable: false);

  List<UserLogEvent> get visibleMyLogs => myLogs
      .where(
        (log) => log.isAlive && !burnedMyLogIds.contains(log.id),
      )
      .toList(growable: false);

  EventsState copyWith({
    List<UserLogEvent>? globalLogs,
    List<UserLogEvent>? myLogs,
    Set<String>? burnedGlobalIds,
    Set<String>? burnedMyLogIds,
    bool? globalLoading,
    bool? myLogsLoading,
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
        burnedGlobalIds: burnedGlobalIds ?? this.burnedGlobalIds,
        burnedMyLogIds: burnedMyLogIds ?? this.burnedMyLogIds,
        globalLoading: globalLoading ?? this.globalLoading,
        myLogsLoading: myLogsLoading ?? this.myLogsLoading,
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
  static const _loadTimeout = Duration(seconds: 15);

  final EventsRepository _repository;
  final String _userId;

  StreamSubscription<List<UserLogEvent>>? _globalSub;
  Timer? _globalLoadTimer;
  Timer? _myLogsLoadTimer;

  EventsCubit({
    required EventsRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId,
        super(const EventsState()) {
    _start();
  }

  void _logError(String source, Object err, [StackTrace? st]) {
    debugPrint('FIREBASE ERROR: $err');
    debugPrint('[EventsCubit] CATCH REACHED: $source');
    if (err is FirebaseException) {
      final line =
          '[EventsCubit] $source | FirebaseException '
          'plugin=${err.plugin} code=${err.code} message=${err.message}';
      developer.log(line, name: 'EventsCubit', error: err, stackTrace: st);
      debugPrint(line);
    } else {
      developer.log(
        '[EventsCubit] $source | $err',
        name: 'EventsCubit',
        error: err,
        stackTrace: st,
      );
      debugPrint('[EventsCubit] $source | $err');
    }
  }

  void _start() {
    debugPrint('[EventsCubit] >>> BOTTOM SHEET DATA LOAD START uid=$_userId');
    _armGlobalTimeout();
    _armMyLogsTimeout();
    _loadGlobalInitial();
    _subscribeGlobal();
    _loadMyLogs();
  }

  void markGlobalEventBurned(String eventId) {
    if (isClosed || state.burnedGlobalIds.contains(eventId)) return;
    emit(
      state.copyWith(
        burnedGlobalIds: {...state.burnedGlobalIds, eventId},
      ),
    );
  }

  void markMyLogBurned(String logId) {
    if (isClosed || state.burnedMyLogIds.contains(logId)) return;
    emit(
      state.copyWith(
        burnedMyLogIds: {...state.burnedMyLogIds, logId},
      ),
    );
  }

  Set<String> _pruneBurnedIds(
    Iterable<String> aliveIds,
    Set<String> burnedIds,
  ) {
    if (burnedIds.isEmpty) return burnedIds;
    return burnedIds.intersection(aliveIds.toSet());
  }

  void _armGlobalTimeout() {
    _globalLoadTimer?.cancel();
    _globalLoadTimer = Timer(_loadTimeout, () {
      if (isClosed || !state.globalLoading) return;
      debugPrint(
        '[EventsCubit] global load timeout after ${_loadTimeout.inSeconds}s',
      );
      emit(state.copyWith(
        globalLoading: false,
        globalError: eventsNetworkTimeoutKey,
      ));
    });
  }

  void _armMyLogsTimeout() {
    _myLogsLoadTimer?.cancel();
    _myLogsLoadTimer = Timer(_loadTimeout, () {
      if (isClosed || !state.myLogsLoading) return;
      debugPrint(
        '[EventsCubit] myLogs load timeout after ${_loadTimeout.inSeconds}s',
      );
      emit(state.copyWith(
        myLogsLoading: false,
        myLogsError: eventsNetworkTimeoutKey,
        clearMyLogsWarning: true,
      ));
    });
  }

  void _clearGlobalTimeout() {
    _globalLoadTimer?.cancel();
    _globalLoadTimer = null;
  }

  void _clearMyLogsTimeout() {
    _myLogsLoadTimer?.cancel();
    _myLogsLoadTimer = null;
  }

  Future<void> _loadGlobalInitial() async {
    debugPrint('[EventsCubit] >>> _loadGlobalInitial calling fetchGlobalEvents');
    try {
      final logs = await _repository
          .fetchGlobalEvents()
          .timeout(_loadTimeout);
      if (isClosed) return;
      _clearGlobalTimeout();
      debugPrint('[EventsCubit] global initial fetch | count=${logs.length}');
      emit(state.copyWith(
        globalLogs: logs,
        burnedGlobalIds:
            _pruneBurnedIds(logs.map((m) => m.id), state.burnedGlobalIds),
        globalLoading: false,
        clearGlobalError: true,
      ));
    } on FirebaseException catch (err, st) {
      if (isClosed) return;
      _clearGlobalTimeout();
      debugPrint('FIREBASE ERROR: $err');
      _logError('fetchGlobalEvents', err, st);
      emit(state.copyWith(
        globalLoading: false,
        globalError: _repository.formatUiError(err),
      ));
    } on TimeoutException catch (err, st) {
      if (isClosed) return;
      _clearGlobalTimeout();
      _logError('fetchGlobalEvents timeout', err, st);
      emit(state.copyWith(
        globalLoading: false,
        globalError: eventsNetworkTimeoutKey,
      ));
    } catch (err, st) {
      if (isClosed) return;
      _clearGlobalTimeout();
      debugPrint('FIREBASE ERROR: $err');
      _logError('fetchGlobalEvents', err, st);
      emit(state.copyWith(
        globalLoading: false,
        globalError: _repository.formatUiError(err),
      ));
    } finally {
      if (!isClosed && state.globalLoading) {
        debugPrint('[EventsCubit] global finally — forcing loading=false');
        emit(state.copyWith(
          globalLoading: false,
          globalError: state.globalError ?? eventsNetworkTimeoutKey,
        ));
      }
    }
  }

  void _subscribeGlobal() {
    _globalSub?.cancel();
    _globalSub = _repository.watchGlobalEvents().listen(
      (logs) {
        if (isClosed) return;
        _clearGlobalTimeout();
        debugPrint('[EventsCubit] global stream | count=${logs.length}');
        emit(state.copyWith(
          globalLogs: logs,
          burnedGlobalIds:
            _pruneBurnedIds(logs.map((m) => m.id), state.burnedGlobalIds),
          globalLoading: false,
          clearGlobalError: true,
        ));
      },
      onError: (Object err, StackTrace st) {
        if (isClosed) return;
        _clearGlobalTimeout();
        debugPrint('FIREBASE ERROR: $err');
        _logError('watchGlobalEvents', err, st);
        emit(state.copyWith(
          globalLoading: false,
          globalError: _mapEventsError(err),
        ));
      },
      cancelOnError: false,
    );
  }

  Future<void> _loadMyLogs() async {
    debugPrint('[EventsCubit] >>> _loadMyLogs calling fetchMyLogs');
    try {
      final payload = await _repository
          .fetchMyLogs(_userId)
          .timeout(_loadTimeout);
      if (isClosed) return;
      _clearMyLogsTimeout();
      debugPrint(
        '[EventsCubit] myLogs loaded | count=${payload.logs.length} '
        'warning=${payload.warning} error=${payload.error}',
      );
      emit(state.copyWith(
        myLogs: payload.logs,
        burnedMyLogIds: _pruneBurnedIds(
          payload.logs.map((m) => m.id),
          state.burnedMyLogIds,
        ),
        myLogsLoading: false,
        myLogsWarning: payload.warning,
        myLogsError: payload.error,
        clearMyLogsError: payload.error == null,
      ));
    } on TimeoutException catch (err, st) {
      if (isClosed) return;
      _clearMyLogsTimeout();
      _logError('fetchMyLogs timeout', err, st);
      emit(state.copyWith(
        myLogsLoading: false,
        myLogsError: eventsNetworkTimeoutKey,
        clearMyLogsWarning: true,
      ));
    } catch (err, st) {
      if (isClosed) return;
      _clearMyLogsTimeout();
      debugPrint('FIREBASE ERROR: $err');
      _logError('fetchMyLogs', err, st);
      emit(state.copyWith(
        myLogsLoading: false,
        myLogsError: _mapEventsError(err),
        clearMyLogsWarning: true,
      ));
    } finally {
      if (!isClosed && state.myLogsLoading) {
        debugPrint('[EventsCubit] myLogs finally — forcing loading=false');
        emit(state.copyWith(
          myLogsLoading: false,
          myLogsError: state.myLogsError ?? eventsNetworkTimeoutKey,
          clearMyLogsWarning: state.myLogsError != null,
        ));
      }
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(
      globalLoading: true,
      myLogsLoading: true,
      clearGlobalError: true,
      clearMyLogsError: true,
      clearMyLogsWarning: true,
    ));
    _armGlobalTimeout();
    _armMyLogsTimeout();
    await Future.wait([
      _loadGlobalInitial(),
      _loadMyLogs(),
    ]);
  }

  String _mapEventsError(Object err) => _repository.formatUiError(err);

  @override
  Future<void> close() {
    _clearGlobalTimeout();
    _clearMyLogsTimeout();
    _globalSub?.cancel();
    return super.close();
  }
}
