/// Аргументы для [GlobalChatScreen] при переходе с карты.
class GlobalChatLaunchArgs {
  final String userId;
  final String nickname;
  final String avatar;
  final String? previewText;

  const GlobalChatLaunchArgs({
    required this.userId,
    required this.nickname,
    this.avatar = 'lev.png',
    this.previewText,
  });
}
