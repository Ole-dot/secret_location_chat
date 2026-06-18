import 'package:cloud_firestore/cloud_firestore.dart';

class SharedTarget {
  final double latitude;
  final double longitude;
  final DateTime? updatedAt;
  final String? setByUserId;

  const SharedTarget({
    required this.latitude,
    required this.longitude,
    this.updatedAt,
    this.setByUserId,
  });

  factory SharedTarget.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw const FormatException('missing shared target');
    }
    final ts = data['updatedAt'];
    return SharedTarget(
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      updatedAt: ts is Timestamp ? ts.toDate() : null,
      setByUserId: data['setByUserId'] as String?,
    );
  }
}
