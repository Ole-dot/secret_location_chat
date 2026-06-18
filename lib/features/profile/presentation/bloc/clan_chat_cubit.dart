import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/clan/clan_repository.dart';
import 'package:secret_location_chat/data/models/clan_chat_message.dart';

class ClanChatState {
  final String clanOwnerId;
  final String chatId;
  final String chatName;
  final List<ClanChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool isClearing;
  final String? successMessage;
  final String? error;

  const ClanChatState({
    required this.clanOwnerId,
    required this.chatId,
    required this.chatName,
    this.messages = const [],
    this.isLoading = true,
    this.isSending = false,
    this.isClearing = false,
    this.successMessage,
    this.error,
  });

  ClanChatState copyWith({
    String? clanOwnerId,
    String? chatId,
    String? chatName,
    List<ClanChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isClearing,
    String? successMessage,
    String? error,
    bool clearSuccess = false,
    bool clearError = false,
  }) =>
      ClanChatState(
        clanOwnerId: clanOwnerId ?? this.clanOwnerId,
        chatId: chatId ?? this.chatId,
        chatName: chatName ?? this.chatName,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        isClearing: isClearing ?? this.isClearing,
        successMessage:
            clearSuccess ? null : (successMessage ?? this.successMessage),
        error: clearError ? null : (error ?? this.error),
      );
}

class ClanChatCubit extends Cubit<ClanChatState> {
  final ClanRepository _repository;
  final String userId;
  final String authorName;

  StreamSubscription<List<ClanChatMessage>>? _chatSub;

  ClanChatCubit({
    required ClanRepository repository,
    required this.userId,
    required this.authorName,
    required String chatId,
    required String chatName,
  })  : _repository = repository,
        super(
          ClanChatState(
            clanOwnerId: userId,
            chatId: chatId,
            chatName: chatName,
          ),
        ) {
    _init();
  }

  Future<void> _init() async {
    try {
      final clanOwnerId = await _repository.resolveClanOwnerId(userId);
      if (isClosed) return;
      emit(state.copyWith(clanOwnerId: clanOwnerId, isLoading: false));
      _chatSub?.cancel();
      _chatSub = _repository
          .watchClanChat(clanOwnerId: clanOwnerId, chatId: state.chatId)
          .listen(
        (messages) {
          if (isClosed) return;
          emit(state.copyWith(messages: messages));
        },
        onError: (err) {
          if (isClosed) return;
          emit(state.copyWith(error: mapFirebaseError(err)));
        },
      );
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: mapFirebaseError(err)));
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    emit(state.copyWith(isSending: true, clearError: true, clearSuccess: true));
    try {
      await _repository.sendClanChatMessage(
        clanOwnerId: state.clanOwnerId,
        chatId: state.chatId,
        authorUid: userId,
        authorName: authorName,
        text: trimmed,
      );
      emit(state.copyWith(isSending: false, clearError: true));
    } catch (err) {
      emit(state.copyWith(
        isSending: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  Future<void> clearHistory() async {
    if (state.isClearing) return;
    emit(state.copyWith(
      isClearing: true,
      clearError: true,
      clearSuccess: true,
    ));
    try {
      await _repository.clearClanChat(
        clanOwnerId: state.clanOwnerId,
        chatId: state.chatId,
      );
      emit(state.copyWith(
        isClearing: false,
        messages: const [],
        successMessage: 'CHAT HISTORY PURGED',
        clearError: true,
      ));
    } catch (err) {
      emit(state.copyWith(
        isClearing: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  @override
  Future<void> close() {
    _chatSub?.cancel();
    return super.close();
  }
}
