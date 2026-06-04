import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/chat/global_chat_repository.dart';
import 'package:secret_location_chat/data/models/chat_message_model.dart';

abstract class GlobalChatEvent {
  const GlobalChatEvent();
}

class GlobalChatStartedEvent extends GlobalChatEvent {
  const GlobalChatStartedEvent();
}

class GlobalChatMessagesUpdatedEvent extends GlobalChatEvent {
  final List<ChatMessage> messages;
  const GlobalChatMessagesUpdatedEvent(this.messages);
}

class GlobalChatSendEvent extends GlobalChatEvent {
  final String text;
  const GlobalChatSendEvent(this.text);
}

class GlobalChatStreamErrorEvent extends GlobalChatEvent {
  final Object error;
  const GlobalChatStreamErrorEvent(this.error);
}

abstract class GlobalChatState {
  const GlobalChatState();
}

class GlobalChatInitialState extends GlobalChatState {
  const GlobalChatInitialState();
}

class GlobalChatReadyState extends GlobalChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  const GlobalChatReadyState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  GlobalChatReadyState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) =>
      GlobalChatReadyState(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        error: clearError ? null : (error ?? this.error),
      );
}

class GlobalChatBloc extends Bloc<GlobalChatEvent, GlobalChatState> {
  final GlobalChatRepository _repo;
  final String userId;
  final String nickname;
  final String avatar;

  StreamSubscription<List<ChatMessage>>? _sub;

  GlobalChatBloc({
    required GlobalChatRepository repo,
    required this.userId,
    required this.nickname,
    required this.avatar,
  })  : _repo = repo,
        super(const GlobalChatInitialState()) {
    on<GlobalChatStartedEvent>(_onStarted);
    on<GlobalChatMessagesUpdatedEvent>(_onMessages);
    on<GlobalChatStreamErrorEvent>(_onStreamError);
    on<GlobalChatSendEvent>(_onSend);
  }

  void _onStarted(
    GlobalChatStartedEvent e,
    Emitter<GlobalChatState> emit,
  ) {
    _sub?.cancel();
    emit(const GlobalChatReadyState());
    _sub = _repo.watchMessages().listen(
      (msgs) => add(GlobalChatMessagesUpdatedEvent(msgs)),
      onError: (Object err, StackTrace _) {
        add(GlobalChatStreamErrorEvent(err));
      },
    );
  }

  void _onMessages(
    GlobalChatMessagesUpdatedEvent e,
    Emitter<GlobalChatState> emit,
  ) {
    final current = state;
    if (current is GlobalChatReadyState) {
      emit(current.copyWith(messages: e.messages, clearError: true));
    }
  }

  void _onStreamError(
    GlobalChatStreamErrorEvent e,
    Emitter<GlobalChatState> emit,
  ) {
    final current = state;
    if (current is GlobalChatReadyState) {
      emit(current.copyWith(error: mapFirebaseError(e.error)));
    }
  }

  Future<void> _onSend(
    GlobalChatSendEvent e,
    Emitter<GlobalChatState> emit,
  ) async {
    final current = state;
    if (current is! GlobalChatReadyState) return;

    final text = e.text.trim();
    if (text.isEmpty) return;

    emit(current.copyWith(isSending: true, clearError: true));
    try {
      await _repo.sendMessage(
        text: text,
        userId: userId,
        nickname: nickname,
        avatar: avatar,
      );
      final latest = state;
      if (latest is GlobalChatReadyState) {
        emit(latest.copyWith(isSending: false, clearError: true));
      }
    } catch (err) {
      final latest = state;
      if (latest is GlobalChatReadyState) {
        emit(latest.copyWith(
          isSending: false,
          error: mapFirebaseError(err),
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
