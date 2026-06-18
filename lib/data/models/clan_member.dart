import 'package:cloud_firestore/cloud_firestore.dart';

class ClanMember {
  final String userId;
  final String email;
  final String username;
  final String avatar;
  final String status;
  final DateTime? joinedAt;
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationAt;

  const ClanMember({
    required this.userId,
    required this.email,
    required this.username,
    required this.avatar,
    required this.status,
    this.joinedAt,
    this.latitude,
    this.longitude,
    this.lastLocationAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  factory ClanMember.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final joined = data['joinedAt'];
    final lastLoc = data['lastLocationAt'];
    return ClanMember(
      userId: data['userId'] as String? ?? id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? 'User',
      avatar: data['avatar'] as String? ?? 'lev.png',
      status: data['status'] as String? ?? 'pending',
      joinedAt: joined is Timestamp ? joined.toDate() : null,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      lastLocationAt: lastLoc is Timestamp ? lastLoc.toDate() : null,
    );
  }
}
