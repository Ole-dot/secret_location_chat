import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String giftName;
  final String assetPath;
  final DateTime? purchasedAt;

  const InventoryItem({
    required this.id,
    required this.giftName,
    required this.assetPath,
    required this.purchasedAt,
  });

  factory InventoryItem.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final ts = data['purchasedAt'];
    return InventoryItem(
      id: id,
      giftName: data['giftName'] as String? ?? '',
      assetPath: data['assetPath'] as String? ?? '',
      purchasedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
