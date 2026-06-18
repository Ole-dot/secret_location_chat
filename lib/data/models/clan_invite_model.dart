import 'package:cloud_firestore/cloud_firestore.dart';

class ClanInviteModel {
  final String inviteId;
  final String fromUserId;
  final String fromEmail;
  final String fromUsername;
  final String fromAvatar;
  final String toUserId;
  final String status;
  final DateTime? createdAt;

  const ClanInviteModel({
    required this.inviteId,
    required this.fromUserId,
    required this.fromEmail,
    required this.fromUsername,
    required this.fromAvatar,
    required this.toUserId,
    required this.status,
    this.createdAt,
  });

  factory ClanInviteModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final created = data['createdAt'];
    return ClanInviteModel(
      inviteId: data['inviteId'] as String? ?? id,
      fromUserId: data['fromUserId'] as String? ?? '',
      fromEmail: data['fromEmail'] as String? ?? '',
      fromUsername: data['fromUsername'] as String? ?? 'User',
      fromAvatar: data['fromAvatar'] as String? ?? 'lev.png',
      toUserId: data['toUserId'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }
}
