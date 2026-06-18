import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/friends/friends_repository.dart';
import 'package:secret_location_chat/data/models/friendship_status.dart';
import 'package:secret_location_chat/data/models/user_model.dart';

class UserProfileState {
  final UserModel targetUser;
  final FriendshipStatus friendshipStatus;
  final bool isActionInProgress;
  final String? successMessage;
  final String? error;

  const UserProfileState({
    required this.targetUser,
    this.friendshipStatus = FriendshipStatus.none,
    this.isActionInProgress = false,
    this.successMessage,
    this.error,
  });

  UserProfileState copyWith({
    UserModel? targetUser,
    FriendshipStatus? friendshipStatus,
    bool? isActionInProgress,
    String? successMessage,
    String? error,
    bool clearSuccess = false,
    bool clearError = false,
  }) =>
      UserProfileState(
        targetUser: targetUser ?? this.targetUser,
        friendshipStatus: friendshipStatus ?? this.friendshipStatus,
        isActionInProgress: isActionInProgress ?? this.isActionInProgress,
        successMessage:
            clearSuccess ? null : (successMessage ?? this.successMessage),
        error: clearError ? null : (error ?? this.error),
      );
}

class UserProfileCubit extends Cubit<UserProfileState> {
  final FriendsRepository _friendsRepository;
  final UserModel currentUser;
  StreamSubscription<FriendshipStatus>? _statusSub;

  UserProfileCubit({
    required FriendsRepository friendsRepository,
    required this.currentUser,
    required UserModel targetUser,
  })  : _friendsRepository = friendsRepository,
        super(UserProfileState(targetUser: targetUser)) {
    _watchFriendship();
  }

  void _watchFriendship() {
    _statusSub?.cancel();
    _statusSub = _friendsRepository
        .watchFriendshipStatus(
          currentUserId: currentUser.uid,
          otherUserId: state.targetUser.uid,
        )
        .listen(
      (status) {
        if (isClosed) return;
        emit(state.copyWith(friendshipStatus: status, clearError: true));
      },
      onError: (err) {
        if (isClosed) return;
        emit(state.copyWith(error: mapFirebaseError(err)));
      },
    );
  }

  Future<void> addFriend() async {
    if (state.isActionInProgress) return;
    emit(state.copyWith(isActionInProgress: true, clearError: true, clearSuccess: true));

    try {
      await _friendsRepository.sendFriendRequest(
        currentUser: currentUser,
        target: state.targetUser,
      );
      if (isClosed) return;
      emit(state.copyWith(
        isActionInProgress: false,
        successMessage: 'FRIEND REQUEST TRANSMITTED',
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        isActionInProgress: false,
        error: _mapFriendError(err),
      ));
    }
  }

  Future<void> acceptFriend() async {
    if (state.isActionInProgress) return;
    emit(state.copyWith(isActionInProgress: true, clearError: true, clearSuccess: true));

    try {
      await _friendsRepository.acceptFriendRequest(
        currentUserId: currentUser.uid,
        otherUserId: state.targetUser.uid,
      );
      if (isClosed) return;
      emit(state.copyWith(
        isActionInProgress: false,
        successMessage: 'CONNECTION ESTABLISHED',
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        isActionInProgress: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  Future<void> removeFriend() async {
    if (state.isActionInProgress) return;
    emit(state.copyWith(isActionInProgress: true, clearError: true, clearSuccess: true));

    try {
      await _friendsRepository.removeFriend(
        currentUserId: currentUser.uid,
        otherUserId: state.targetUser.uid,
      );
      if (isClosed) return;
      emit(state.copyWith(
        isActionInProgress: false,
        friendshipStatus: FriendshipStatus.none,
        successMessage: 'NETWORK DISCONNECTED',
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        isActionInProgress: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  String _mapFriendError(Object err) {
    if (err is StateError && err.message == 'CANNOT_FRIEND_SELF') {
      return 'CANNOT ADD YOURSELF';
    }
    return mapFirebaseError(err);
  }

  @override
  Future<void> close() {
    _statusSub?.cancel();
    return super.close();
  }
}
