class UserModel {
  final String uid;
  final String email;
  final String username;
  final String avatar;
  final bool isAnonymousMode;
  final DateTime createdAt;
  final int stonesBalance;
  final int stonesLifetimeEarned;
  final int stonesLifetimeSpent;
  final int stonesVersion;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.avatar = 'lev.png',
    required this.isAnonymousMode,
    required this.createdAt,
    this.stonesBalance = 0,
    this.stonesLifetimeEarned = 0,
    this.stonesLifetimeSpent = 0,
    this.stonesVersion = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        username: (json['nickname'] as String?) ?? json['username'] as String,
        avatar: json['avatar'] as String? ?? 'lev.png',
        isAnonymousMode: json['isAnonymousMode'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        stonesBalance: (json['stonesBalance'] as num?)?.toInt() ?? 0,
        stonesLifetimeEarned:
            (json['stonesLifetimeEarned'] as num?)?.toInt() ?? 0,
        stonesLifetimeSpent:
            (json['stonesLifetimeSpent'] as num?)?.toInt() ?? 0,
        stonesVersion: (json['stonesVersion'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'username': username,
        'nickname': username,
        'avatar': avatar,
        'isAnonymousMode': isAnonymousMode,
        'createdAt': createdAt.toIso8601String(),
        'stonesBalance': stonesBalance,
        'stonesLifetimeEarned': stonesLifetimeEarned,
        'stonesLifetimeSpent': stonesLifetimeSpent,
        'stonesVersion': stonesVersion,
      };

  UserModel copyWith({
    String? username,
    String? avatar,
    int? stonesBalance,
    int? stonesLifetimeEarned,
    int? stonesLifetimeSpent,
    int? stonesVersion,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        username: username ?? this.username,
        avatar: avatar ?? this.avatar,
        isAnonymousMode: isAnonymousMode,
        createdAt: createdAt,
        stonesBalance: stonesBalance ?? this.stonesBalance,
        stonesLifetimeEarned:
            stonesLifetimeEarned ?? this.stonesLifetimeEarned,
        stonesLifetimeSpent: stonesLifetimeSpent ?? this.stonesLifetimeSpent,
        stonesVersion: stonesVersion ?? this.stonesVersion,
      );
}
