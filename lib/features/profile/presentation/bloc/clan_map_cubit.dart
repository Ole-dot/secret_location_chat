import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/data/clan/clan_repository.dart';
import 'package:secret_location_chat/data/models/clan_member.dart';
import 'package:secret_location_chat/data/models/shared_target.dart';

class ClanMapState {
  final String clanOwnerId;
  final SharedTarget? sharedTarget;
  final List<ClanMember> members;
  final bool isResolving;

  const ClanMapState({
    required this.clanOwnerId,
    this.sharedTarget,
    this.members = const [],
    this.isResolving = true,
  });

  ClanMapState copyWith({
    String? clanOwnerId,
    SharedTarget? sharedTarget,
    List<ClanMember>? members,
    bool? isResolving,
    bool clearSharedTarget = false,
  }) =>
      ClanMapState(
        clanOwnerId: clanOwnerId ?? this.clanOwnerId,
        sharedTarget:
            clearSharedTarget ? null : (sharedTarget ?? this.sharedTarget),
        members: members ?? this.members,
        isResolving: isResolving ?? this.isResolving,
      );
}

class ClanMapCubit extends Cubit<ClanMapState> {
  final ClanRepository _repository;
  final String userId;

  StreamSubscription<SharedTarget?>? _targetSub;
  StreamSubscription<List<ClanMember>>? _membersSub;

  ClanMapCubit({
    required ClanRepository repository,
    required this.userId,
  })  : _repository = repository,
        super(ClanMapState(clanOwnerId: userId, isResolving: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _repository.ensureClanProfile(userId);
      final clanOwnerId = await _repository.resolveClanOwnerId(userId);
      if (isClosed) return;
      emit(state.copyWith(clanOwnerId: clanOwnerId, isResolving: false));
      _subscribe(clanOwnerId);
    } catch (err) {
      if (isClosed) return;
      emit(state.copyWith(isResolving: false));
    }
  }

  void _subscribe(String clanOwnerId) {
    _targetSub?.cancel();
    _membersSub?.cancel();

    _targetSub = _repository.watchSharedTarget(clanOwnerId).listen(
      (target) {
        if (isClosed) return;
        emit(
          target == null
              ? state.copyWith(clearSharedTarget: true)
              : state.copyWith(sharedTarget: target),
        );
      },
    );

    _membersSub = _repository.watchClanMembers(clanOwnerId).listen(
      (members) {
        if (isClosed) return;
        emit(state.copyWith(members: members));
      },
      onError: (_) {},
    );
  }

  Future<void> syncMemberLocation(double latitude, double longitude) async {
    try {
      await _repository.updateMemberLocation(
        clanOwnerId: state.clanOwnerId,
        memberUserId: userId,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _targetSub?.cancel();
    _membersSub?.cancel();
    return super.close();
  }
}
