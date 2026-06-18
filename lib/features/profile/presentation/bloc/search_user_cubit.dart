import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/friends/friends_repository.dart';
import 'package:secret_location_chat/data/models/friendship_status.dart';
import 'package:secret_location_chat/data/models/user_model.dart';
import 'package:secret_location_chat/data/user/user_repository.dart';

class SearchUserState {
  final bool isSearching;
  final List<UserModel> results;
  final bool notFound;
  final String? errorMessage;
  final String? emptyQueryMessage;
  final Map<String, FriendshipStatus> friendshipByUserId;
  final Set<String> sendingFriendRequestUids;
  final String? friendActionError;

  const SearchUserState({
    this.isSearching = false,
    this.results = const [],
    this.notFound = false,
    this.errorMessage,
    this.emptyQueryMessage,
    this.friendshipByUserId = const {},
    this.sendingFriendRequestUids = const {},
    this.friendActionError,
  });

  SearchUserState copyWith({
    bool? isSearching,
    List<UserModel>? results,
    bool? notFound,
    String? errorMessage,
    String? emptyQueryMessage,
    Map<String, FriendshipStatus>? friendshipByUserId,
    Set<String>? sendingFriendRequestUids,
    String? friendActionError,
    bool clearError = false,
    bool clearEmptyQuery = false,
    bool clearResults = false,
    bool clearFriendActionError = false,
  }) =>
      SearchUserState(
        isSearching: isSearching ?? this.isSearching,
        results: clearResults ? const [] : (results ?? this.results),
        notFound: notFound ?? this.notFound,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        emptyQueryMessage: clearEmptyQuery
            ? null
            : (emptyQueryMessage ?? this.emptyQueryMessage),
        friendshipByUserId: friendshipByUserId ?? this.friendshipByUserId,
        sendingFriendRequestUids:
            sendingFriendRequestUids ?? this.sendingFriendRequestUids,
        friendActionError: clearFriendActionError
            ? null
            : (friendActionError ?? this.friendActionError),
      );

  FriendshipStatus friendshipFor(String userId) =>
      friendshipByUserId[userId] ?? FriendshipStatus.none;

  bool isSendingFriendRequest(String userId) =>
      sendingFriendRequestUids.contains(userId);
}

class SearchUserCubit extends Cubit<SearchUserState> {
  final UserRepository _userRepository;
  final FriendsRepository _friendsRepository;
  final UserModel _currentUser;

  SearchUserCubit({
    required UserRepository userRepository,
    required FriendsRepository friendsRepository,
    required UserModel currentUser,
  })  : _userRepository = userRepository,
        _friendsRepository = friendsRepository,
        _currentUser = currentUser,
        super(const SearchUserState());

  Future<void> search(String rawQuery, {required String emptyQueryHint}) async {
    final query = rawQuery.trim();
    print('SEARCH TRIGGERED: $query');

    if (query.isEmpty) {
      emit(state.copyWith(
        clearResults: true,
        notFound: false,
        clearError: true,
        emptyQueryMessage: emptyQueryHint,
        friendshipByUserId: const {},
      ));
      return;
    }

    emit(state.copyWith(
      isSearching: true,
      clearResults: true,
      notFound: false,
      clearError: true,
      clearEmptyQuery: true,
      friendshipByUserId: const {},
    ));

    try {
      final results = await _userRepository.searchUsers(query);
      print('RESULTS FOUND: ${results.length}');
      if (isClosed) return;

      final filtered = results
          .where((user) => user.uid != _currentUser.uid)
          .toList();

      emit(state.copyWith(
        isSearching: false,
        results: filtered,
        notFound: filtered.isEmpty,
        clearError: true,
        clearEmptyQuery: true,
      ));

      await _loadFriendshipStatuses(filtered);
    } catch (err, stackTrace) {
      debugPrint('SEARCH ERROR: ${formatErrorForDisplay(err)}');
      debugPrint(stackTrace.toString());
      if (isClosed) return;
      emit(state.copyWith(
        isSearching: false,
        clearResults: true,
        notFound: false,
        errorMessage: mapFirebaseError(err),
        clearEmptyQuery: true,
        friendshipByUserId: const {},
      ));
    }
  }

  Future<void> _loadFriendshipStatuses(List<UserModel> users) async {
    if (users.isEmpty || isClosed) return;

    final statuses = <String, FriendshipStatus>{};
    await Future.wait(
      users.map((user) async {
        statuses[user.uid] = await _friendsRepository.getFriendshipStatus(
          currentUserId: _currentUser.uid,
          otherUserId: user.uid,
        );
      }),
    );

    if (isClosed) return;
    emit(state.copyWith(friendshipByUserId: statuses));
  }

  Future<void> sendFriendRequest(UserModel target) async {
    if (state.isSendingFriendRequest(target.uid)) return;

    final status = state.friendshipFor(target.uid);
    if (status != FriendshipStatus.none) return;

    print(
      'DEBUG: SearchUserCubit.sendFriendRequest '
      'from ${_currentUser.uid} to ${target.uid}',
    );

    final sending = Set<String>.from(state.sendingFriendRequestUids)
      ..add(target.uid);
    emit(state.copyWith(
      sendingFriendRequestUids: sending,
      clearFriendActionError: true,
    ));

    try {
      await _friendsRepository.sendFriendRequest(
        currentUser: _currentUser,
        target: target,
      );
      if (isClosed) return;

      print('DEBUG: Friend request UI state -> pendingOutgoing for ${target.uid}');

      final updatedSending = Set<String>.from(state.sendingFriendRequestUids)
        ..remove(target.uid);
      emit(state.copyWith(
        sendingFriendRequestUids: updatedSending,
        friendshipByUserId: {
          ...state.friendshipByUserId,
          target.uid: FriendshipStatus.pendingOutgoing,
        },
      ));
    } catch (err, stackTrace) {
      print('ERROR: Failed to send friend request: $err');
      debugPrint(formatErrorForDisplay(err));
      debugPrint(stackTrace.toString());
      if (isClosed) return;

      final updatedSending = Set<String>.from(state.sendingFriendRequestUids)
        ..remove(target.uid);
      emit(state.copyWith(
        sendingFriendRequestUids: updatedSending,
        friendActionError: _mapFriendError(err),
      ));
    }
  }

  String _mapFriendError(Object err) {
    if (err is StateError) {
      return switch (err.message) {
        'CANNOT_FRIEND_SELF' => 'CANNOT ADD YOURSELF',
        'INVALID_FRIEND_REQUEST_IDS' => 'INVALID USER IDS',
        _ => mapFirebaseError(err),
      };
    }
    return mapFirebaseError(err);
  }
}
