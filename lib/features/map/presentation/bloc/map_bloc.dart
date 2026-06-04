import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/geo/geo_message_repository.dart';
import 'package:secret_location_chat/data/models/geo_message_model.dart';
import 'package:secret_location_chat/data/prefs/user_prefs_service.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class MapEvent {}
class MapInitEvent extends MapEvent {}
class MapMessagesUpdatedEvent extends MapEvent {
  final List<GeoMessage> messages;
  MapMessagesUpdatedEvent(this.messages);
}
class MapSendMessageEvent extends MapEvent {
  final String text;
  final bool isAnonymous;
  final Duration ttl;
  MapSendMessageEvent({required this.text, required this.isAnonymous, required this.ttl});
}
class MapSelectMessageEvent extends MapEvent {
  final GeoMessage? message;
  MapSelectMessageEvent(this.message);
}
class MapToggleAnonEvent extends MapEvent {}
class MapCycleStyleEvent extends MapEvent {}
class MapPlanChangedEvent extends MapEvent {
  final UserPlan plan;
  MapPlanChangedEvent(this.plan);
}

class MapProfileUpdatedEvent extends MapEvent {
  final String username;
  MapProfileUpdatedEvent(this.username);
}

// ─── State ────────────────────────────────────────────────────────────────────

class MapState {
  final List<GeoMessage> messages;
  final Position? userPosition;
  final GeoMessage? selectedMessage;
  final bool isAnonymous;
  final UserPlan plan;
  final MapStyle mapStyle;
  final bool isLoading;
  final String? error;

  const MapState({
    this.messages = const [],
    this.userPosition,
    this.selectedMessage,
    this.isAnonymous = false,
    this.plan = UserPlan.free,
    this.mapStyle = MapStyle.dark,
    this.isLoading = false,
    this.error,
  });

  bool get isPremium => plan != UserPlan.free;

  MapState copyWith({
    List<GeoMessage>? messages,
    Position? userPosition,
    GeoMessage? selectedMessage,
    bool clearSelected = false,
    bool? isAnonymous,
    UserPlan? plan,
    MapStyle? mapStyle,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => MapState(
    messages: messages ?? this.messages,
    userPosition: userPosition ?? this.userPosition,
    selectedMessage: clearSelected ? null : (selectedMessage ?? this.selectedMessage),
    isAnonymous: isAnonymous ?? this.isAnonymous,
    plan: plan ?? this.plan,
    mapStyle: mapStyle ?? this.mapStyle,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class MapBloc extends Bloc<MapEvent, MapState> {
  final GeoMessageRepository _msgRepo;
  final UserPrefsService _prefs;
  final String _uid;
  String _username;
  StreamSubscription<List<GeoMessage>>? _msgSub;

  MapBloc({
    required GeoMessageRepository msgRepo,
    required UserPrefsService prefs,
    required String uid,
    required String username,
  })  : _msgRepo = msgRepo,
        _prefs = prefs,
        _uid = uid,
        _username = username,
        super(const MapState()) {
    on<MapInitEvent>(_onInit);
    on<MapMessagesUpdatedEvent>(_onMessages);
    on<MapSendMessageEvent>(_onSend);
    on<MapSelectMessageEvent>(_onSelect);
    on<MapToggleAnonEvent>(_onToggleAnon);
    on<MapCycleStyleEvent>(_onCycleStyle);
    on<MapPlanChangedEvent>(_onPlanChanged);
    on<MapProfileUpdatedEvent>(_onProfileUpdated);
  }

  Future<void> _onInit(MapInitEvent e, Emitter<MapState> emit) async {
    emit(state.copyWith(isLoading: true));
    final isAnon = await _prefs.getAnonMode();
    final plan   = await _prefs.getPlan();
    final style  = await _prefs.getMapStyle();

    Position? position;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
      }
    } catch (_) {}

    emit(state.copyWith(isAnonymous: isAnon, plan: plan, mapStyle: style, userPosition: position, isLoading: false));
    _msgSub = _msgRepo.watchMessages().listen((msgs) => add(MapMessagesUpdatedEvent(msgs)));
  }

  void _onMessages(MapMessagesUpdatedEvent e, Emitter<MapState> emit) =>
      emit(state.copyWith(messages: e.messages));

  Future<void> _onSend(MapSendMessageEvent e, Emitter<MapState> emit) async {
    final pos = state.userPosition;
    if (pos == null) { emit(state.copyWith(error: 'Геолокация недоступна')); return; }
    try {
      await _msgRepo.sendMessage(
        authorUid: _uid,
        authorName: _username,
        isAnonymous: e.isAnonymous,
        text: e.text,
        latitude: pos.latitude,
        longitude: pos.longitude,
        ttl: e.ttl,
      );
      emit(state.copyWith(clearError: true));
    } catch (err) {
      emit(state.copyWith(error: mapFirebaseError(err)));
    }
  }

  void _onSelect(MapSelectMessageEvent e, Emitter<MapState> emit) =>
      e.message == null ? emit(state.copyWith(clearSelected: true)) : emit(state.copyWith(selectedMessage: e.message));

  Future<void> _onToggleAnon(MapToggleAnonEvent e, Emitter<MapState> emit) async {
    final v = !state.isAnonymous;
    await _prefs.setAnonMode(v);
    emit(state.copyWith(isAnonymous: v));
  }

  Future<void> _onCycleStyle(MapCycleStyleEvent e, Emitter<MapState> emit) async {
    final styles = MapStyle.values;
    final next = styles[(styles.indexOf(state.mapStyle) + 1) % styles.length];
    await _prefs.setMapStyle(next);
    emit(state.copyWith(mapStyle: next));
  }

  Future<void> _onPlanChanged(MapPlanChangedEvent e, Emitter<MapState> emit) async {
    await _prefs.setPlan(e.plan);
    emit(state.copyWith(plan: e.plan));
  }

  void _onProfileUpdated(MapProfileUpdatedEvent e, Emitter<MapState> emit) {
    _username = e.username;
  }

  @override
  Future<void> close() { _msgSub?.cancel(); return super.close(); }
}
