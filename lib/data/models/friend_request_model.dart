import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestModel {
  final String requestId;
  final String senderId;
  final String recipientId;
  final String senderName;
  final String username;
  final String avatar;
  final String status;
  final DateTime? createdAt;

  const FriendRequestModel({
    required this.requestId,
    required this.senderId,
    required this.recipientId,
    required this.senderName,
    required this.username,
    required this.avatar,
    required this.status,
    this.createdAt,
  });

  factory FriendRequestModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final created = data['createdAt'] ?? data['timestamp'];
    return FriendRequestModel(
      requestId: id,
      senderId: data['senderId'] as String? ?? '',
      recipientId: data['recipientId'] as String? ?? '',
      senderName: data['senderName'] as String? ??
          data['username'] as String? ??
          'User',
      username: data['username'] as String? ?? 'User',
      avatar: data['avatar'] as String? ?? 'lev.png',
      status: data['status'] as String? ?? 'pending',
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }
}
