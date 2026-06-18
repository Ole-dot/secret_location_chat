import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/clan/clan_repository.dart';
import 'package:secret_location_chat/data/models/clan_chat_room.dart';
import 'package:secret_location_chat/data/models/clan_member.dart';
import 'package:secret_location_chat/data/models/user_model.dart';
import 'package:secret_location_chat/data/user/user_repository.dart';

class ClanState {
  final String clanOwnerId;
  final List<ClanMember> members;
  final List<ClanChatRoom> chats;
  final List<UserModel> searchResults;
  final bool isSearching;
  final UserModel? emailSearchUser;
  final bool isEmailSearching;
  final bool emailSearchNotFound;
  final bool emailTargetInClan;
  final bool isBootstrapping;
  final bool clanJustCreated;
  final String? invitingUserId;
  final String? kickingMemberUserId;
  final bool notFound;
  final String? successMessage;
  final String? error;

  const ClanState({
    required this.clanOwnerId,
    this.members = const [],
    this.chats = const [],
    this.searchResults = const [],
    this.isSearching = false,
    this.emailSearchUser,
    this.isEmailSearching = false,
    this.emailSearchNotFound = false,
    this.emailTargetInClan = false,
    this.isBootstrapping = true,
    this.clanJustCreated = false,
    this.invitingUserId,
    this.kickingMemberUserId,
    this.notFound = false,
    this.successMessage,
    this.error,
  });

  bool get isClanOwner => clanOwnerId.isNotEmpty;

  bool isClanAdmin(String userId) => clanOwnerId == userId;

  ClanState copyWith({
    String? clanOwnerId,
    List<ClanMember>? members,
    List<ClanChatRoom>? chats,
    List<UserModel>? searchResults,
    bool? isSearching,
    UserModel? emailSearchUser,
    bool? isEmailSearching,
    bool? emailSearchNotFound,
    bool? emailTargetInClan,
    bool? isBootstrapping,
    bool? clanJustCreated,
    String? invitingUserId,
    String? kickingMemberUserId,
    bool? notFound,
    String? successMessage,
    String? error,
    bool clearSearchResults = false,
    bool clearEmailSearchUser = false,
    bool clearInvitingUserId = false,
    bool clearKickingMemberUserId = false,
    bool clearSuccess = false,
    bool clearError = false,
    bool clearClanJustCreated = false,
  }) =>
      ClanState(
        clanOwnerId: clanOwnerId ?? this.clanOwnerId,
        members: members ?? this.members,
        chats: chats ?? this.chats,
        searchResults:
            clearSearchResults ? const [] : (searchResults ?? this.searchResults),
        isSearching: isSearching ?? this.isSearching,
        emailSearchUser: clearEmailSearchUser
            ? null
            : (emailSearchUser ?? this.emailSearchUser),
        isEmailSearching: isEmailSearching ?? this.isEmailSearching,
        emailSearchNotFound: emailSearchNotFound ?? this.emailSearchNotFound,
        emailTargetInClan: emailTargetInClan ?? this.emailTargetInClan,
        isBootstrapping: isBootstrapping ?? this.isBootstrapping,
        clanJustCreated: clearClanJustCreated
            ? false
            : (clanJustCreated ?? this.clanJustCreated),
        invitingUserId: clearInvitingUserId
            ? null
            : (invitingUserId ?? this.invitingUserId),
        kickingMemberUserId: clearKickingMemberUserId
            ? null
            : (kickingMemberUserId ?? this.kickingMemberUserId),
        notFound: notFound ?? this.notFound,
        successMessage:
            clearSuccess ? null : (successMessage ?? this.successMessage),
        error: clearError ? null : (error ?? this.error),
      );
}

class ClanCubit extends Cubit<ClanState> {
  final ClanRepository _clanRepository;
  final UserRepository _userRepository;
  final String userId;
  final String ownerEmail;
  final String ownerUsername;
  final String ownerAvatar;

  StreamSubscription<List<ClanMember>>? _membersSub;
  StreamSubscription<List<ClanChatRoom>>? _chatsSub;

  ClanCubit({
    required ClanRepository clanRepository,
    required UserRepository userRepository,
    required this.userId,
    required this.ownerEmail,
    required this.ownerUsername,
    required this.ownerAvatar,
  })  : _clanRepository = clanRepository,
        _userRepository = userRepository,
        super(ClanState(clanOwnerId: userId)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final bootstrap = await _clanRepository.bootstrapClan(userId);
      final clanOwnerId = await _clanRepository.resolveClanOwnerId(userId);
      if (isClosed) return;
      emit(
        state.copyWith(
          clanOwnerId: clanOwnerId,
          isBootstrapping: false,
          clanJustCreated: bootstrap.created,
          successMessage: bootstrap.created
              ? 'CLAN ONLINE — DEFAULT CHANNELS DEPLOYED'
              : null,
        ),
      );
      _watchMembers(clanOwnerId);
      _watchChats(clanOwnerId);
    } catch (err) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isBootstrapping: false,
          error: mapFirebaseError(err),
        ),
      );
    }
  }

  void acknowledgeClanCreated() {
    if (!state.clanJustCreated) return;
    emit(state.copyWith(clearClanJustCreated: true));
  }

  void _watchMembers(String clanOwnerId) {
    _membersSub?.cancel();
    _membersSub = _clanRepository.watchClanMembers(clanOwnerId).listen(
      (members) {
        if (isClosed) return;
        emit(state.copyWith(members: members));
      },
      onError: (err) {
        if (isClosed) return;
        emit(state.copyWith(error: mapFirebaseError(err)));
      },
    );
  }

  void _watchChats(String clanOwnerId) {
    _chatsSub?.cancel();
    _chatsSub = _clanRepository.watchClanChats(clanOwnerId).listen(
      (chats) {
        if (isClosed) return;
        emit(state.copyWith(chats: chats));
      },
      onError: (err) {
        if (isClosed) return;
        emit(state.copyWith(error: mapFirebaseError(err)));
      },
    );
  }

  Future<void> searchByNickname(String query) async {
    final normalized = query.trim();
    print('SEARCH TRIGGERED: $normalized');
    if (normalized.isEmpty) {
      emit(state.copyWith(
        clearSearchResults: true,
        notFound: false,
        error: 'ВВЕДИТЕ НИК',
        clearSuccess: true,
      ));
      return;
    }

    emit(state.copyWith(
      isSearching: true,
      clearSearchResults: true,
      notFound: false,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final results = await _userRepository.searchUsers(normalized);
      print('RESULTS FOUND: ${results.length}');
      if (isClosed) return;
      emit(state.copyWith(
        isSearching: false,
        searchResults: results,
        notFound: results.isEmpty,
        clearError: true,
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        isSearching: false,
        clearSearchResults: true,
        notFound: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  void clearEmailSearch() {
    emit(state.copyWith(
      clearEmailSearchUser: true,
      emailSearchNotFound: false,
      emailTargetInClan: false,
      isEmailSearching: false,
      clearError: true,
    ));
  }

  Future<void> searchByEmail(String email) async {
    final normalized = email.trim();
    if (normalized.isEmpty) {
      emit(state.copyWith(
        clearEmailSearchUser: true,
        emailSearchNotFound: false,
        error: 'ВВЕДИТЕ EMAIL',
        clearSuccess: true,
      ));
      return;
    }

    emit(state.copyWith(
      isEmailSearching: true,
      clearEmailSearchUser: true,
      emailSearchNotFound: false,
      emailTargetInClan: false,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      final user = await _userRepository.findUserByEmail(normalized.toLowerCase());
      if (isClosed) return;

      if (user == null) {
        emit(state.copyWith(
          isEmailSearching: false,
          emailSearchNotFound: true,
          clearEmailSearchUser: true,
          emailTargetInClan: false,
        ));
        return;
      }

      final inClan = await _clanRepository.isUserInAnyClan(
        user.uid,
        ourClanOwnerId: state.clanOwnerId,
      );
      if (isClosed) return;

      emit(state.copyWith(
        isEmailSearching: false,
        emailSearchUser: user,
        emailSearchNotFound: false,
        emailTargetInClan: inClan,
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        isEmailSearching: false,
        clearEmailSearchUser: true,
        emailSearchNotFound: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  Future<void> addMemberByEmail(UserModel target) async {
    if (state.invitingUserId != null) return;

    emit(state.copyWith(
      invitingUserId: target.uid,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      await _clanRepository.addMemberToClan(
        clanOwnerId: state.clanOwnerId,
        target: target,
      );
      if (isClosed) return;
      emit(state.copyWith(
        clearInvitingUserId: true,
        clearEmailSearchUser: true,
        emailSearchNotFound: false,
        emailTargetInClan: false,
        successMessage: 'MEMBER ADDED TO CLAN',
        clearError: true,
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        clearInvitingUserId: true,
        error: _mapClanError(err),
      ));
    }
  }

  Future<void> inviteUser(UserModel target) async {
    if (state.invitingUserId != null) return;

    emit(state.copyWith(
      invitingUserId: target.uid,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      await _clanRepository.sendClanInvite(
        clanOwnerId: state.clanOwnerId,
        fromEmail: ownerEmail,
        fromUsername: ownerUsername,
        fromAvatar: ownerAvatar,
        target: target,
      );
      if (isClosed) return;
      emit(state.copyWith(
        clearInvitingUserId: true,
        successMessage: 'CLAN INVITE TRANSMITTED',
        clearSearchResults: true,
        notFound: false,
        clearError: true,
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        clearInvitingUserId: true,
        error: _mapClanError(err),
      ));
    }
  }

  Future<void> kickMember(ClanMember member) async {
    if (!state.isClanAdmin(userId)) return;
    if (member.userId == userId) return;
    if (state.kickingMemberUserId != null) return;

    emit(state.copyWith(
      kickingMemberUserId: member.userId,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      await _clanRepository.removeMemberFromClan(
        clanOwnerId: state.clanOwnerId,
        memberUserId: member.userId,
      );
      if (isClosed) return;
      emit(state.copyWith(
        clearKickingMemberUserId: true,
        successMessage: 'MEMBER TERMINATED FROM SYNDICATE',
        clearError: true,
      ));
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(
        clearKickingMemberUserId: true,
        error: _mapClanError(err),
      ));
    }
  }

  String _mapClanError(Object err) {
    if (err is StateError) {
      return switch (err.message) {
        'CANNOT_INVITE_SELF' => 'CANNOT ADD YOURSELF',
        'CANNOT_KICK_SELF' => 'CANNOT KICK YOURSELF',
        'ALREADY_IN_CLAN' => 'USER ALREADY IN CLAN',
        'INVITE_ALREADY_SENT' => 'INVITE ALREADY PENDING',
        _ => mapFirebaseError(err),
      };
    }
    return mapFirebaseError(err);
  }

  @override
  Future<void> close() {
    _membersSub?.cancel();
    _chatsSub?.cancel();
    return super.close();
  }
}
