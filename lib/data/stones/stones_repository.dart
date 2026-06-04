import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secret_location_chat/data/models/transaction_model.dart';

class StonesRepository {
  final FirebaseFirestore _firestore;

  StonesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<int> watchStonesBalance(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map(
          (doc) => (doc.data()?['stonesBalance'] as num?)?.toInt() ?? 0,
        );
  }

  Future<int> fetchStonesBalance(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return (doc.data()?['stonesBalance'] as num?)?.toInt() ?? 0;
  }

  Future<void> ensureStonesFields(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    if (data.containsKey('stonesBalance')) return;

    await _firestore.collection('users').doc(userId).set({
      'stonesBalance': 0,
      'stonesLifetimeEarned': 0,
      'stonesLifetimeSpent': 0,
      'stonesVersion': 0,
      'stonesUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<int> addStones({
    required String userId,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw StateError('INVALID_STONES_AMOUNT');
    }

    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'stonesBalance': FieldValue.increment(amount),
      'stonesLifetimeEarned': FieldValue.increment(amount),
      'stonesVersion': FieldValue.increment(1),
      'stonesUpdatedAt': FieldValue.serverTimestamp(),
    });

    return fetchStonesBalance(userId);
  }

  Future<bool> hasCompletedTransaction({
    required String userId,
    required String idempotencyKey,
  }) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('idempotencyKey', isEqualTo: idempotencyKey)
        .where('status', isEqualTo: 'completed')
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<int> creditFromPurchase({
    required String userId,
    required int amount,
    required String productId,
    required String storePlatform,
    required String purchaseToken,
    required String orderId,
    required String idempotencyKey,
  }) async {
    if (amount <= 0) {
      throw StateError('INVALID_STONES_AMOUNT');
    }

    final duplicate = await hasCompletedTransaction(
      userId: userId,
      idempotencyKey: idempotencyKey,
    );
    if (duplicate) {
      return fetchStonesBalance(userId);
    }

    final userRef = _firestore.collection('users').doc(userId);
    final txRef = _firestore.collection('transactions').doc();

    return _firestore.runTransaction<int>((transaction) async {
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) {
        throw StateError('USER_NOT_FOUND');
      }

      final data = userSnap.data()!;
      final balanceBefore = (data['stonesBalance'] as num?)?.toInt() ?? 0;
      final lifetimeEarned =
          (data['stonesLifetimeEarned'] as num?)?.toInt() ?? 0;
      final version = (data['stonesVersion'] as num?)?.toInt() ?? 0;
      final balanceAfter = balanceBefore + amount;
      final nextVersion = version + 1;
      final now = FieldValue.serverTimestamp();

      transaction.update(userRef, {
        'stonesBalance': balanceAfter,
        'stonesLifetimeEarned': lifetimeEarned + amount,
        'stonesVersion': nextVersion,
        'stonesUpdatedAt': now,
      });

      final tx = TransactionModel(
        transactionId: txRef.id,
        userId: userId,
        type: TransactionType.iapPurchase,
        status: TransactionStatus.completed,
        amount: amount,
        balanceBefore: balanceBefore,
        balanceAfter: balanceAfter,
        stonesVersion: nextVersion,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        productId: productId,
        storePlatform: storePlatform,
        purchaseToken: purchaseToken,
        orderId: orderId,
        idempotencyKey: idempotencyKey,
      );

      transaction.set(txRef, {
        ...tx.toFirestore(),
        'createdAt': now,
        'completedAt': now,
      });

      return balanceAfter;
    });
  }

  Future<int> debitForGift({
    required String userId,
    required int amount,
    required String giftId,
    required String giftEventId,
    required String recipientUserId,
    required String idempotencyKey,
  }) async {
    if (amount <= 0) {
      throw StateError('INVALID_STONES_AMOUNT');
    }

    final userRef = _firestore.collection('users').doc(userId);
    final txRef = _firestore.collection('transactions').doc();

    return _firestore.runTransaction<int>((transaction) async {
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) {
        throw StateError('USER_NOT_FOUND');
      }

      final data = userSnap.data()!;
      final balanceBefore = (data['stonesBalance'] as num?)?.toInt() ?? 0;
      if (balanceBefore < amount) {
        throw StateError('INSUFFICIENT_STONES');
      }

      final lifetimeSpent =
          (data['stonesLifetimeSpent'] as num?)?.toInt() ?? 0;
      final version = (data['stonesVersion'] as num?)?.toInt() ?? 0;
      final balanceAfter = balanceBefore - amount;
      final nextVersion = version + 1;
      final now = FieldValue.serverTimestamp();

      transaction.update(userRef, {
        'stonesBalance': balanceAfter,
        'stonesLifetimeSpent': lifetimeSpent + amount,
        'stonesVersion': nextVersion,
        'stonesUpdatedAt': now,
      });

      final tx = TransactionModel(
        transactionId: txRef.id,
        userId: userId,
        type: TransactionType.giftPurchase,
        status: TransactionStatus.completed,
        amount: -amount,
        balanceBefore: balanceBefore,
        balanceAfter: balanceAfter,
        stonesVersion: nextVersion,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        giftId: giftId,
        giftEventId: giftEventId,
        recipientUserId: recipientUserId,
        idempotencyKey: idempotencyKey,
      );

      transaction.set(txRef, {
        ...tx.toFirestore(),
        'createdAt': now,
        'completedAt': now,
      });

      return balanceAfter;
    });
  }

  Future<int> creditFromMinigame({
    required String userId,
    required int amount,
    required int level,
    required String sessionId,
  }) async {
    if (amount <= 0) {
      throw StateError('INVALID_STONES_AMOUNT');
    }

    final idempotencyKey = 'minigame_${userId}_${sessionId}_$level';
    final duplicate = await hasCompletedTransaction(
      userId: userId,
      idempotencyKey: idempotencyKey,
    );
    if (duplicate) {
      return fetchStonesBalance(userId);
    }

    final userRef = _firestore.collection('users').doc(userId);
    final txRef = _firestore.collection('transactions').doc();

    return _firestore.runTransaction<int>((transaction) async {
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists) {
        throw StateError('USER_NOT_FOUND');
      }

      final data = userSnap.data()!;
      final balanceBefore = (data['stonesBalance'] as num?)?.toInt() ?? 0;
      final lifetimeEarned =
          (data['stonesLifetimeEarned'] as num?)?.toInt() ?? 0;
      final version = (data['stonesVersion'] as num?)?.toInt() ?? 0;
      final balanceAfter = balanceBefore + amount;
      final nextVersion = version + 1;
      final now = FieldValue.serverTimestamp();

      transaction.update(userRef, {
        'stonesBalance': balanceAfter,
        'stonesLifetimeEarned': lifetimeEarned + amount,
        'stonesVersion': nextVersion,
        'stonesUpdatedAt': now,
      });

      final tx = TransactionModel(
        transactionId: txRef.id,
        userId: userId,
        type: TransactionType.adminGrant,
        status: TransactionStatus.completed,
        amount: amount,
        balanceBefore: balanceBefore,
        balanceAfter: balanceAfter,
        stonesVersion: nextVersion,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        productId: 'terminal_hack_level_$level',
        idempotencyKey: idempotencyKey,
      );

      transaction.set(txRef, {
        ...tx.toFirestore(),
        'createdAt': now,
        'completedAt': now,
      });

      return balanceAfter;
    });
  }
}
