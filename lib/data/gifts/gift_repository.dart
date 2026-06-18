import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/models/gift_catalog_item.dart';
import 'package:secret_location_chat/data/models/inventory_item.dart';
import 'package:uuid/uuid.dart';

class GiftSendResult {
  final String giftEventId;
  final String transactionId;
  final int balanceAfter;

  const GiftSendResult({
    required this.giftEventId,
    required this.transactionId,
    required this.balanceAfter,
  });
}

class GiftRepository {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  GiftRepository({
    FirebaseFirestore? firestore,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid();

  Future<List<GiftCatalogItem>> fetchCatalog() async {
    final snapshot = await _firestore
        .collection('gift_catalog')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    if (snapshot.docs.isEmpty) {
      return GiftCatalogItem.defaults;
    }

    return snapshot.docs
        .map(
          (doc) => GiftCatalogItem.fromFirestore(doc.id, doc.data()),
        )
        .toList();
  }

  Stream<List<InventoryItem>> watchInventory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('inventory')
        .orderBy('purchasedAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InventoryItem.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> buyToInventory({
    required String userId,
    required GiftCatalogItem gift,
  }) async {
    final cost = gift.stoneCost;
    if (cost <= 0) {
      throw StateError('INVALID_GIFT_PRICE');
    }

    debugPrint(
      '[GiftRepository] buyToInventory start '
      'userId=$userId giftId=${gift.giftId} stoneCost=$cost',
    );

    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) {
          throw StateError('USER_NOT_FOUND');
        }
        final userData = userSnap.data()!;
        final balanceBefore = (userData['stonesBalance'] as num?)?.toInt() ?? 0;
        debugPrint(
          '[GiftRepository] balanceBefore=$balanceBefore required=$cost',
        );
        if (balanceBefore < cost) {
          throw StateError('INSUFFICIENT_STONES');
        }

        final lifetimeSpent =
            (userData['stonesLifetimeSpent'] as num?)?.toInt() ?? 0;
        final version = (userData['stonesVersion'] as num?)?.toInt() ?? 0;
        final balanceAfter = balanceBefore - cost;
        final nextVersion = version + 1;
        final now = FieldValue.serverTimestamp();

        final txRef = _firestore.collection('transactions').doc();
        final inventoryRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('inventory')
            .doc(_uuid.v4());

        transaction.update(userRef, {
          'stonesBalance': balanceAfter,
          'stonesLifetimeSpent': lifetimeSpent + cost,
          'stonesVersion': nextVersion,
          'stonesUpdatedAt': now,
        });

        transaction.set(txRef, {
          'transactionId': txRef.id,
          'userId': userId,
          'type': 'gift_inventory_purchase',
          'status': 'completed',
          'amount': -cost,
          'balanceBefore': balanceBefore,
          'balanceAfter': balanceAfter,
          'stonesVersion': nextVersion,
          'giftId': gift.giftId,
          'idempotencyKey': 'stash_${userId}_${inventoryRef.id}',
          'createdAt': now,
          'completedAt': now,
        });

        transaction.set(inventoryRef, {
          'giftId': gift.giftId,
          'giftName': gift.name,
          'assetPath': gift.assetKey,
          'tier': gift.tier,
          'stoneCost': cost,
          'purchasedAt': now,
        });
      });
      debugPrint('[GiftRepository] buyToInventory success giftId=${gift.giftId}');
    } catch (error, stackTrace) {
      logPurchaseError('GiftRepository.buyToInventory', error, stackTrace);
      rethrow;
    }
  }

  Future<GiftSendResult> sendGift({
    required String senderUserId,
    required String senderNickname,
    required String senderAvatar,
    required String recipientUserId,
    required GiftCatalogItem gift,
    String message = '',
    String chatType = 'global',
    bool postToGlobalChat = true,
  }) async {
    if (senderUserId == recipientUserId) {
      throw StateError('CANNOT_GIFT_SELF');
    }

    final giftEventId = _uuid.v4();
    final idempotencyKey = 'gift_${senderUserId}_${giftEventId}';
    final giftEventRef = _firestore.collection('gift_events').doc(giftEventId);
    final recipientInboxRef = _firestore
        .collection('users')
        .doc(recipientUserId)
        .collection('received_gifts')
        .doc(giftEventId);
    final senderOutboxRef = _firestore
        .collection('users')
        .doc(senderUserId)
        .collection('sent_gifts')
        .doc(giftEventId);

    String? chatMessageId;
    DocumentReference<Map<String, dynamic>>? messageRef;

    if (postToGlobalChat && chatType == 'global') {
      messageRef = _firestore.collection('messages').doc();
      chatMessageId = messageRef.id;
    }

    final balanceAfter = await _firestore.runTransaction<int>((transaction) async {
      final senderRef = _firestore.collection('users').doc(senderUserId);
      final senderSnap = await transaction.get(senderRef);
      if (!senderSnap.exists) {
        throw StateError('USER_NOT_FOUND');
      }

      final senderData = senderSnap.data()!;
      final balanceBefore =
          (senderData['stonesBalance'] as num?)?.toInt() ?? 0;
      if (balanceBefore < gift.stoneCost) {
        throw StateError('INSUFFICIENT_STONES');
      }

      final lifetimeSpent =
          (senderData['stonesLifetimeSpent'] as num?)?.toInt() ?? 0;
      final version = (senderData['stonesVersion'] as num?)?.toInt() ?? 0;
      final balanceAfterTx = balanceBefore - gift.stoneCost;
      final nextVersion = version + 1;
      final now = FieldValue.serverTimestamp();
      final txRef = _firestore.collection('transactions').doc();

      transaction.update(senderRef, {
        'stonesBalance': balanceAfterTx,
        'stonesLifetimeSpent': lifetimeSpent + gift.stoneCost,
        'stonesVersion': nextVersion,
        'stonesUpdatedAt': now,
      });

      transaction.set(txRef, {
        'transactionId': txRef.id,
        'userId': senderUserId,
        'type': 'gift_purchase',
        'status': 'completed',
        'amount': -gift.stoneCost,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfterTx,
        'stonesVersion': nextVersion,
        'giftId': gift.giftId,
        'giftEventId': giftEventId,
        'recipientUserId': recipientUserId,
        'idempotencyKey': idempotencyKey,
        'createdAt': now,
        'completedAt': now,
      });

      transaction.set(giftEventRef, {
        'giftEventId': giftEventId,
        'giftId': gift.giftId,
        'senderUserId': senderUserId,
        'recipientUserId': recipientUserId,
        'stoneCost': gift.stoneCost,
        'message': message,
        'chatType': chatType,
        'chatMessageId': chatMessageId,
        'transactionId': txRef.id,
        'status': 'delivered',
        'createdAt': now,
      });

      transaction.set(recipientInboxRef, {
        'giftEventId': giftEventId,
        'giftId': gift.giftId,
        'senderUserId': senderUserId,
        'stoneCost': gift.stoneCost,
        'status': 'unread',
        'createdAt': now,
      });

      transaction.set(senderOutboxRef, {
        'giftEventId': giftEventId,
        'giftId': gift.giftId,
        'recipientUserId': recipientUserId,
        'stoneCost': gift.stoneCost,
        'status': 'sent',
        'createdAt': now,
      });

      if (messageRef != null) {
        final giftLabel = gift.name;
        final chatText = message.trim().isEmpty
            ? '🎁 $giftLabel'
            : '🎁 $giftLabel · ${message.trim()}';

        transaction.set(messageRef, {
          'text': chatText,
          'userId': senderUserId,
          'nickname': senderNickname,
          'avatar': senderAvatar,
          'timestamp': now,
          'giftEventId': giftEventId,
          'giftId': gift.giftId,
          'isGift': true,
        });
      }

      return balanceAfterTx;
    });

    return GiftSendResult(
      giftEventId: giftEventId,
      transactionId: idempotencyKey,
      balanceAfter: balanceAfter,
    );
  }
}
