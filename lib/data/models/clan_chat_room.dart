import 'package:cloud_firestore/cloud_firestore.dart';

class ClanChatRoom {
  final String id;
  final String name;
  final DateTime? createdAt;
  final int order;

  const ClanChatRoom({
    required this.id,
    required this.name,
    this.createdAt,
    this.order = 0,
  });

  factory ClanChatRoom.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final created = data['createdAt'];
    return ClanChatRoom(
      id: data['id'] as String? ?? id,
      name: data['name'] as String? ?? 'Channel',
      createdAt: created is Timestamp ? created.toDate() : null,
      order: data['order'] as int? ?? 0,
    );
  }
}

const kDefaultClanChatNames = [
  'Main Terminal',
  'Black Market',
  'Missions',
];
