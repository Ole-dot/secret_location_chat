import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/geo/geo_message_repository.dart';
import 'package:secret_location_chat/data/models/geo_message_model.dart';
import 'package:secret_location_chat/data/models/map_thread_message.dart';

class MapMessageChatState {
  final GeoMessage parentMessage;
  final List<MapThreadMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool isDeleting;
  final bool threadExpired;
  final String? successMessage;
  final String? error;

  const MapMessageChatState({
    required this.parentMessage,
    this.messages = const [],
    this.isLoading = true,
    this.isSending = false,
    this.isDeleting = false,
    this.threadExpired = false,
    this.successMessage,
    this.error,
  });

  MapMessageChatState copyWith({
    GeoMessage? parentMessage,
    List<MapThreadMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isDeleting,
    bool? threadExpired,
    String? successMessage,
    String? error,
    bool clearSuccess = false,
    bool clearError = false,
  }) =>
      MapMessageChatState(
        parentMessage: parentMessage ?? this.parentMessage,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        isDeleting: isDeleting ?? this.isDeleting,
        threadExpired: threadExpired ?? this.threadExpired,
        successMessage:
            clearSuccess ? null : (successMessage ?? this.successMessage),
        error: clearError ? null : (error ?? this.error),
      );
}

class MapMessageChatCubit extends Cubit<MapMessageChatState> {
  final GeoMessageRepository _repository;
  final String currentUserId;
  final String currentUsername;
  final bool isAnonymous;

  StreamSubscription<List<MapThreadMessage>>? _messagesSub;
  StreamSubscription<GeoMessage?>? _parentSub;

  MapMessageChatCubit({
    required GeoMessageRepository repository,
    required GeoMessage parentMessage,
    required this.currentUserId,
    required this.currentUsername,
    required this.isAnonymous,
  })  : _repository = repository,
        super(MapMessageChatState(parentMessage: parentMessage)) {
    _watchThread();
  }

  bool get isParentAuthor => state.parentMessage.authorUid == currentUserId;

  void _watchThread() {
    final parentId = state.parentMessage.id;

    _parentSub = _repository.watchMessage(parentId).listen(
      (parent) {
        if (isClosed) return;
        if (parent == null || !parent.isAlive) {
          emit(state.copyWith(threadExpired: true, isLoading: false));
          return;
        }
        emit(state.copyWith(
          parentMessage: parent,
          threadExpired: false,
        ));
      },
      onError: (err) {
        if (isClosed) return;
        emit(state.copyWith(error: mapFirebaseError(err)));
      },
    );

    _messagesSub = _repository.watchChatMessages(parentId).listen(
      (messages) {
        if (isClosed) return;
        emit(state.copyWith(
          messages: messages,
          isLoading: false,
          clearError: true,
        ));
      },
      onError: (err) {
        if (isClosed) return;
        emit(state.copyWith(
          isLoading: false,
          error: mapFirebaseError(err),
        ));
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty || state.isSending || state.threadExpired) return;

    emit(state.copyWith(isSending: true, clearError: true, clearSuccess: true));

    try {
      await _repository.sendChatMessage(
        parentId: state.parentMessage.id,
        authorUid: currentUserId,
        authorName: currentUsername,
        isAnonymous: isAnonymous,
        text: normalized,
      );
      if (isClosed) return;
      emit(state.copyWith(isSending: false));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        isSending: false,
        error: _mapThreadError(err),
      ));
    }
  }

  Future<bool> deleteThread() async {
    if (!isParentAuthor || state.isDeleting) return false;

    emit(state.copyWith(isDeleting: true, clearError: true, clearSuccess: true));

    try {
      await _repository.deleteMessageWithThread(
        messageId: state.parentMessage.id,
        authorUid: currentUserId,
      );
      if (isClosed) return true;
      emit(state.copyWith(isDeleting: false));
      return true;
    } catch (err) {
      if (isClosed) return false;
      emit(state.copyWith(
        isDeleting: false,
        error: mapFirebaseError(err),
      ));
      return false;
    }
  }

  String _mapThreadError(Object err) {
    if (err is StateError) {
      return switch (err.message) {
        'PARENT_NOT_FOUND' => 'THREAD SIGNAL LOST',
        'PARENT_EXPIRED' => 'THREAD EXPIRED',
        _ => mapFirebaseError(err),
      };
    }
    return mapFirebaseError(err);
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    _parentSub?.cancel();
    return super.close();
  }
}
