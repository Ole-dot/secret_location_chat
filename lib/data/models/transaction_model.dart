enum TransactionType {
  iapPurchase,
  giftPurchase,
  refund,
  adminGrant,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  refunded,
}

class TransactionModel {
  final String transactionId;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final int amount;
  final int balanceBefore;
  final int balanceAfter;
  final int stonesVersion;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? productId;
  final String? storePlatform;
  final String? purchaseToken;
  final String? orderId;
  final String? giftId;
  final String? giftEventId;
  final String? recipientUserId;
  final String idempotencyKey;

  const TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.stonesVersion,
    required this.createdAt,
    this.completedAt,
    this.productId,
    this.storePlatform,
    this.purchaseToken,
    this.orderId,
    this.giftId,
    this.giftEventId,
    this.recipientUserId,
    required this.idempotencyKey,
  });

  Map<String, dynamic> toFirestore() => {
        'transactionId': transactionId,
        'userId': userId,
        'type': _typeToString(type),
        'status': _statusToString(status),
        'amount': amount,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'stonesVersion': stonesVersion,
        'createdAt': createdAt,
        'completedAt': completedAt,
        'productId': productId,
        'storePlatform': storePlatform,
        'purchaseToken': purchaseToken,
        'orderId': orderId,
        'giftId': giftId,
        'giftEventId': giftEventId,
        'recipientUserId': recipientUserId,
        'idempotencyKey': idempotencyKey,
      };

  static String _typeToString(TransactionType type) => switch (type) {
        TransactionType.iapPurchase => 'iap_purchase',
        TransactionType.giftPurchase => 'gift_purchase',
        TransactionType.refund => 'refund',
        TransactionType.adminGrant => 'admin_grant',
      };

  static String _statusToString(TransactionStatus status) => switch (status) {
        TransactionStatus.pending => 'pending',
        TransactionStatus.completed => 'completed',
        TransactionStatus.failed => 'failed',
        TransactionStatus.refunded => 'refunded',
      };
}
