import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/clan_bootstrap_result.dart';
import 'package:secret_location_chat/data/models/clan_chat_message.dart';
import 'package:secret_location_chat/data/models/clan_chat_room.dart';
import 'package:secret_location_chat/data/models/clan_invite_model.dart';
import 'package:secret_location_chat/data/models/clan_member.dart';
import 'package:secret_location_chat/data/models/shared_target.dart';
import 'package:secret_location_chat/data/models/user_model.dart';
import 'package:uuid/uuid.dart';

class ClanRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ClanRepository({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  Future<String> resolveClanOwnerId(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final clanId = doc.data()?['clanOwnerId'] as String?;
    if (clanId != null && clanId.isNotEmpty) return clanId;
    return userId;
  }

  /// Idempotent clan bootstrap: creates owner profile, member row, and default
  /// [chats] channels in a single batch on first run.
  Future<ClanBootstrapResult> bootstrapClan(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userSnap = await userRef.get();
    final userData = userSnap.data() ?? {};
    final existingClanOwnerId = userData['clanOwnerId'] as String?;
    final isMemberOfOtherClan = existingClanOwnerId != null &&
        existingClanOwnerId.isNotEmpty &&
        existingClanOwnerId != userId;

    if (isMemberOfOtherClan) {
      return ClanBootstrapResult(
        created: false,
        clanOwnerId: existingClanOwnerId,
      );
    }

    if (userData['clanChannelsInitialized'] == true) {
      await userRef.collection('clan_members').doc(userId).set(
        {
          'userId': userId,
          'status': 'active',
          'joinedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return ClanBootstrapResult(created: false, clanOwnerId: userId);
    }

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    batch.set(
      userRef,
      {
        'clanOwnerId': userId,
        'clanChannelsInitialized': true,
        'clanCreatedAt': now,
      },
      SetOptions(merge: true),
    );

    batch.set(
      userRef.collection('clan_members').doc(userId),
      {
        'userId': userId,
        'status': 'active',
        'joinedAt': now,
      },
      SetOptions(merge: true),
    );

    for (var i = 0; i < kDefaultClanChatNames.length; i++) {
      final chatId = _uuid.v4();
      batch.set(
        userRef.collection('chats').doc(chatId),
        {
          'id': chatId,
          'name': kDefaultClanChatNames[i],
          'order': i,
          'createdAt': now,
        },
      );
    }

    await batch.commit();
    return ClanBootstrapResult(created: true, clanOwnerId: userId);
  }

  Future<void> ensureClanProfile(String userId) async {
    await bootstrapClan(userId);
  }

  Stream<List<ClanChatRoom>> watchClanChats(String clanOwnerId) {
    return _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('chats')
        .orderBy('order')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ClanChatRoom.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<ClanMember>> watchClanMembers(String clanOwnerId) {
    return _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('clan_members')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ClanMember.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<SharedTarget?> watchSharedTarget(String clanOwnerId) {
    return _firestore.collection('users').doc(clanOwnerId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data();
      final target = data?['sharedTarget'];
      if (target is! Map<String, dynamic>) return null;
      try {
        return SharedTarget.fromMap(target);
      } catch (_) {
        return null;
      }
    });
  }

  Future<void> setSharedTarget({
    required String clanOwnerId,
    required String setByUserId,
    required double latitude,
    required double longitude,
  }) async {
    await _firestore.collection('users').doc(clanOwnerId).set(
      {
        'sharedTarget': {
          'latitude': latitude,
          'longitude': longitude,
          'setByUserId': setByUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateMemberLocation({
    required String clanOwnerId,
    required String memberUserId,
    required double latitude,
    required double longitude,
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('clan_members')
        .doc(memberUserId);

    final snap = await ref.get();
    if (!snap.exists && clanOwnerId != memberUserId) return;

    await ref.set(
      {
        'userId': memberUserId,
        'status': 'active',
        'latitude': latitude,
        'longitude': longitude,
        'lastLocationAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<List<ClanChatMessage>> watchClanChat({
    required String clanOwnerId,
    required String chatId,
  }) {
    final now = Timestamp.fromDate(DateTime.now());
    return _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .limit(100)
        .snapshots()
        .map(
          (snap) {
            final messages = snap.docs
                .map((doc) => ClanChatMessage.fromFirestore(doc.id, doc.data()))
                .where((m) => m.isAlive)
                .toList();
            messages.sort((a, b) {
              final left = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
              final right = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
              return right.compareTo(left);
            });
            return messages;
          },
        );
  }

  Future<void> sendClanChatMessage({
    required String clanOwnerId,
    required String chatId,
    required String authorUid,
    required String authorName,
    required String text,
    Duration ttl = const Duration(hours: 24),
  }) async {
    final now = DateTime.now();
    await _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'authorUid': authorUid,
      'authorName': authorName,
      'text': text.trim(),
      'timestamp': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(ttl)),
    });
  }

  Future<void> clearClanChat({
    required String clanOwnerId,
    required String chatId,
  }) async {
    final col = _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('chats')
        .doc(chatId)
        .collection('messages');
    while (true) {
      final snap = await col.limit(100).get();
      if (snap.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// True when the user belongs to any clan (including their own as owner).
  Future<bool> isUserInAnyClan(
    String targetUserId, {
    required String ourClanOwnerId,
  }) async {
    if (await isAlreadyInClan(
      clanOwnerId: ourClanOwnerId,
      memberUserId: targetUserId,
    )) {
      return true;
    }

    final userDoc = await _firestore.collection('users').doc(targetUserId).get();
    if (!userDoc.exists) return false;

    final clanOwnerId = userDoc.data()?['clanOwnerId'] as String?;
    if (clanOwnerId == null || clanOwnerId.isEmpty) return false;

    if (clanOwnerId == targetUserId) return true;

    final memberDoc = await _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('clan_members')
        .doc(targetUserId)
        .get();

    if (!memberDoc.exists) return false;
    final status = memberDoc.data()?['status'] as String?;
    return status == 'active' || status == 'pending';
  }

  Future<bool> isAlreadyInClan({
    required String clanOwnerId,
    required String memberUserId,
  }) async {
    final doc = await _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('clan_members')
        .doc(memberUserId)
        .get();
    return doc.exists;
  }

  Future<bool> hasPendingInvite({
    required String targetUserId,
    required String fromUserId,
  }) async {
    final snap = await _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('clan_invites')
        .where('fromUserId', isEqualTo: fromUserId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Stream<List<ClanInviteModel>> watchIncomingClanInvites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('clan_invites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ClanInviteModel.fromFirestore(doc.id, doc.data()))
              .where((invite) => invite.status == 'pending')
              .toList(),
        );
  }

  Future<void> acceptClanInvite({
    required String userId,
    required ClanInviteModel invite,
  }) async {
    final batch = _firestore.batch();
    final inviteRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('clan_invites')
        .doc(invite.inviteId);
    final memberRef = _firestore
        .collection('users')
        .doc(invite.fromUserId)
        .collection('clan_members')
        .doc(userId);

    batch.update(inviteRef, {
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      memberRef,
      {
        'userId': userId,
        'status': 'active',
        'joinedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(
      _firestore.collection('users').doc(userId),
      {'clanOwnerId': invite.fromUserId},
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> rejectClanInvite({
    required String userId,
    required ClanInviteModel invite,
  }) async {
    final batch = _firestore.batch();
    final inviteRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('clan_invites')
        .doc(invite.inviteId);
    final memberRef = _firestore
        .collection('users')
        .doc(invite.fromUserId)
        .collection('clan_members')
        .doc(userId);
    final userRef = _firestore.collection('users').doc(userId);

    batch.update(inviteRef, {
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
    batch.delete(memberRef);

    final userSnap = await userRef.get();
    final clanOwnerId = userSnap.data()?['clanOwnerId'] as String?;
    if (clanOwnerId == invite.fromUserId) {
      batch.update(userRef, {'clanOwnerId': FieldValue.delete()});
    }

    await batch.commit();
  }

  Future<void> sendClanInvite({
    required String clanOwnerId,
    required String fromEmail,
    required String fromUsername,
    required String fromAvatar,
    required UserModel target,
  }) async {
    if (clanOwnerId == target.uid) {
      throw StateError('CANNOT_INVITE_SELF');
    }

    final alreadyMember = await isAlreadyInClan(
      clanOwnerId: clanOwnerId,
      memberUserId: target.uid,
    );
    if (alreadyMember) {
      throw StateError('ALREADY_IN_CLAN');
    }

    final pending = await hasPendingInvite(
      targetUserId: target.uid,
      fromUserId: clanOwnerId,
    );
    if (pending) {
      throw StateError('INVITE_ALREADY_SENT');
    }

    final inviteId = _uuid.v4();
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();

    final inviteRef = _firestore
        .collection('users')
        .doc(target.uid)
        .collection('clan_invites')
        .doc(inviteId);

    final memberRef = _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('clan_members')
        .doc(target.uid);

    batch.set(inviteRef, {
      'inviteId': inviteId,
      'fromUserId': clanOwnerId,
      'fromEmail': fromEmail,
      'fromUsername': fromUsername,
      'fromAvatar': fromAvatar,
      'toUserId': target.uid,
      'toEmail': target.email,
      'status': 'pending',
      'createdAt': now,
    });

    batch.set(memberRef, {
      'userId': target.uid,
      'email': target.email,
      'username': target.username,
      'avatar': target.avatar,
      'status': 'pending',
      'joinedAt': now,
    });

    batch.set(
      _firestore.collection('users').doc(target.uid),
      {'clanOwnerId': clanOwnerId},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Directly adds a user to the clan (active member, no invite flow).
  Future<void> addMemberToClan({
    required String clanOwnerId,
    required UserModel target,
  }) async {
    if (clanOwnerId == target.uid) {
      throw StateError('CANNOT_INVITE_SELF');
    }

    final inClan = await isUserInAnyClan(
      target.uid,
      ourClanOwnerId: clanOwnerId,
    );
    if (inClan) {
      throw StateError('ALREADY_IN_CLAN');
    }

    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();

    final memberRef = _firestore
        .collection('users')
        .doc(clanOwnerId)
        .collection('clan_members')
        .doc(target.uid);

    batch.set(memberRef, {
      'userId': target.uid,
      'email': target.email,
      'username': target.username,
      'avatar': target.avatar,
      'status': 'active',
      'joinedAt': now,
    });

    batch.set(
      _firestore.collection('users').doc(target.uid),
      {'clanOwnerId': clanOwnerId},
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> removeMemberFromClan({
    required String clanOwnerId,
    required String memberUserId,
  }) async {
    if (clanOwnerId == memberUserId) {
      throw StateError('CANNOT_KICK_SELF');
    }

    final batch = _firestore.batch();

    batch.delete(
      _firestore
          .collection('users')
          .doc(clanOwnerId)
          .collection('clan_members')
          .doc(memberUserId),
    );

    final memberUserRef = _firestore.collection('users').doc(memberUserId);
    final memberUserSnap = await memberUserRef.get();
    final theirClanOwnerId = memberUserSnap.data()?['clanOwnerId'] as String?;
    if (theirClanOwnerId == clanOwnerId) {
      batch.update(memberUserRef, {'clanOwnerId': FieldValue.delete()});
    }

    await batch.commit();
  }
}
