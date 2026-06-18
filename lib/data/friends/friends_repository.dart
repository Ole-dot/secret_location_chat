import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:secret_location_chat/data/models/friend_request_model.dart';
import 'package:secret_location_chat/data/models/friendship_status.dart';
import 'package:secret_location_chat/data/models/user_model.dart';
class FriendsRepository {
  final FirebaseFirestore _firestore;

  FriendsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _friendRef(
    String ownerId,
    String friendId,
  ) =>
      _firestore
          .collection('users')
          .doc(ownerId)
          .collection('friends')
          .doc(friendId);

  DocumentReference<Map<String, dynamic>> _incomingFriendRequestRef(
    String recipientId,
    String requestId,
  ) =>
      _firestore
          .collection('users')
          .doc(recipientId)
          .collection('friend_requests')
          .doc(requestId);

  Stream<List<FriendRequestModel>> watchIncomingFriendRequests(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friend_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => FriendRequestModel.fromFirestore(doc.id, doc.data()))
              .where((request) => request.status == 'pending')
              .toList(),
        );
  }

  FriendshipStatus resolveFriendshipStatus({
    required DocumentSnapshot<Map<String, dynamic>>? myDoc,
    required DocumentSnapshot<Map<String, dynamic>>? theirDoc,
  }) {
    final myStatus = myDoc?.data()?['status'] as String?;
    final theirStatus = theirDoc?.data()?['status'] as String?;

    if (myStatus == 'accepted' && theirStatus == 'accepted') {
      return FriendshipStatus.friends;
    }
    if (myStatus == 'pending' && theirStatus == 'pending') {
      return FriendshipStatus.pendingOutgoing;
    }
    if (theirStatus == 'pending' && myStatus != 'accepted') {
      return FriendshipStatus.pendingIncoming;
    }
    if (myStatus == 'pending') {
      return FriendshipStatus.pendingOutgoing;
    }
    return FriendshipStatus.none;
  }

  Stream<FriendshipStatus> watchFriendshipStatus({
    required String currentUserId,
    required String otherUserId,
  }) {
    final myRef = _friendRef(currentUserId, otherUserId);
    final theirRef = _friendRef(otherUserId, currentUserId);
    final controller = StreamController<FriendshipStatus>();

    DocumentSnapshot<Map<String, dynamic>>? mySnap;
    DocumentSnapshot<Map<String, dynamic>>? theirSnap;

    void publish() {
      if (controller.isClosed) return;
      controller.add(
        resolveFriendshipStatus(myDoc: mySnap, theirDoc: theirSnap),
      );
    }

    final mySub = myRef.snapshots().listen(
      (doc) {
        mySnap = doc;
        publish();
      },
      onError: controller.addError,
    );
    final theirSub = theirRef.snapshots().listen(
      (doc) {
        theirSnap = doc;
        publish();
      },
      onError: controller.addError,
    );

    controller.onCancel = () async {
      await mySub.cancel();
      await theirSub.cancel();
    };

    return controller.stream;
  }

  Future<FriendshipStatus> getFriendshipStatus({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final results = await Future.wait([
      _friendRef(currentUserId, otherUserId).get(),
      _friendRef(otherUserId, currentUserId).get(),
    ]);
    return resolveFriendshipStatus(
      myDoc: results[0].exists ? results[0] : null,
      theirDoc: results[1].exists ? results[1] : null,
    );
  }

  Future<void> sendFriendRequest({
    required UserModel currentUser,
    required UserModel target,
  }) async {
    final currentUserId = currentUser.uid.trim();
    final targetUserId = target.uid.trim();

    print(
      'DEBUG: Sending friend request from $currentUserId to $targetUserId',
    );

    if (currentUserId.isEmpty || targetUserId.isEmpty) {
      const message =
          'ERROR: Invalid friend request IDs — currentUserId or targetUserId is empty';
      print(message);
      throw StateError('INVALID_FRIEND_REQUEST_IDS');
    }

    if (currentUserId == targetUserId) {
      print('ERROR: Cannot send friend request to self ($currentUserId)');
      throw StateError('CANNOT_FRIEND_SELF');
    }

    final now = FieldValue.serverTimestamp();
    final requestRef = _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('friend_requests')
        .doc();

    final incomingFriendDoc = {
      'friendUserId': currentUserId,
      'username': currentUser.username,
      'avatar': currentUser.avatar,
      'status': 'pending',
      'createdAt': now,
    };
    final outgoingFriendDoc = {
      'friendUserId': targetUserId,
      'username': target.username,
      'avatar': target.avatar,
      'status': 'pending',
      'createdAt': now,
    };
    final friendRequestDoc = {
      'requestId': requestRef.id,
      'recipientId': targetUserId,
      'senderId': currentUserId,
      'senderName': currentUser.username,
      'username': currentUser.username,
      'avatar': currentUser.avatar,
      'status': 'pending',
      'timestamp': now,
      'createdAt': now,
    };

    print(
      'DEBUG: Firestore batch paths — '
      'users/$targetUserId/friends/$currentUserId, '
      'users/$currentUserId/friends/$targetUserId, '
      'users/$targetUserId/friend_requests/${requestRef.id}',
    );
    debugPrint('DEBUG: friend_requests payload: $friendRequestDoc');

    try {
      final batch = _firestore.batch();

      batch.set(_friendRef(targetUserId, currentUserId), incomingFriendDoc);
      batch.set(_friendRef(currentUserId, targetUserId), outgoingFriendDoc);
      batch.set(requestRef, friendRequestDoc);

      await batch.commit();
      print(
        'DEBUG: Friend request committed successfully '
        '($currentUserId -> $targetUserId)',
      );
    } catch (e, stackTrace) {
      print('ERROR: Failed to send friend request: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
  Future<void> acceptFriendRequest({
    required String currentUserId,
    required String otherUserId,
    String? requestId,
  }) async {
    final batch = _firestore.batch();
    batch.update(_friendRef(currentUserId, otherUserId), {
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_friendRef(otherUserId, currentUserId), {
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
    if (requestId != null && requestId.isNotEmpty) {
      batch.update(_incomingFriendRequestRef(currentUserId, requestId), {
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> rejectFriendRequest({
    required String currentUserId,
    required String senderId,
    required String requestId,
  }) async {
    final batch = _firestore.batch();
    batch.delete(_friendRef(currentUserId, senderId));
    batch.delete(_friendRef(senderId, currentUserId));
    batch.delete(_incomingFriendRequestRef(currentUserId, requestId));
    await batch.commit();
  }

  Future<void> removeFriend({
    required String currentUserId,
    required String otherUserId,
  }) async {
    final batch = _firestore.batch();
    batch.delete(_friendRef(currentUserId, otherUserId));
    batch.delete(_friendRef(otherUserId, currentUserId));
    await batch.commit();
  }
}
