import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/data/clan/clan_repository.dart';
import 'package:secret_location_chat/data/friends/friends_repository.dart';
import 'package:secret_location_chat/data/models/clan_invite_model.dart';
import 'package:secret_location_chat/data/models/friend_request_model.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/widgets/cyber_radar_slider.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/widgets/cyber_volume_control.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AppAuthBloc>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: authState is! AppAuthAuthenticatedState
          ? const Center(
              child: Text(
                'ВОЙДИТЕ В АККАУНТ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            )
          : ScreenScrollBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _IncomingFriendRequestsSection(
                    userId: authState.user.uid,
                  ),
                  const SizedBox(height: 24),
                  _IncomingClanInvitesSection(
                    userId: authState.user.uid,
                  ),
                  const SizedBox(height: 32),
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 24),
                  const CyberVolumeControl(),
                  const SizedBox(height: 24),
                  const CyberRadarSlider(),
                  const SizedBox(height: 20),
                  const Text(
                    '// ЖМИ ИЛИ ТЯНИ ДОРОЖКУ ДЛЯ НАСТРОЙКИ //',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _IncomingFriendRequestsSection extends StatelessWidget {
  final String userId;

  const _IncomingFriendRequestsSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    final friendsRepo = context.read<FriendsRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          title: 'ЗАПРОСЫ В ДРУЗЬЯ',
          icon: Icons.person_add_alt_1_outlined,
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<FriendRequestModel>>(
          stream: friendsRepo.watchIncomingFriendRequests(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _LoadingHint();
            }
            if (snapshot.hasError) {
              return _ErrorHint(message: snapshot.error.toString());
            }

            final requests = snapshot.data ?? const [];
            if (requests.isEmpty) {
              return const _EmptyHint(text: 'НЕТ ВХОДЯЩИХ ЗАПРОСОВ');
            }

            return Column(
              children: [
                for (final request in requests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FriendRequestCard(
                      request: request,
                      onAccept: () => _handleAccept(context, request),
                      onReject: () => _handleReject(context, request),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    FriendRequestModel request,
  ) async {
    try {
      await context.read<FriendsRepository>().acceptFriendRequest(
            currentUserId: userId,
            otherUserId: request.senderId,
            requestId: request.requestId,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          content: const Text(
            'СВЯЗЬ УСТАНОВЛЕНА',
            style: TextStyle(
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    } catch (err) {
      if (!context.mounted) return;
      CyberSnackBar.showError(
        context,
        err.toString(),
        backgroundColor: AppColors.surfaceCard,
      );
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    FriendRequestModel request,
  ) async {
    try {
      await context.read<FriendsRepository>().rejectFriendRequest(
            currentUserId: userId,
            senderId: request.senderId,
            requestId: request.requestId,
          );
    } catch (err) {
      if (!context.mounted) return;
      CyberSnackBar.showError(
        context,
        err.toString(),
        backgroundColor: AppColors.surfaceCard,
      );
    }
  }
}

class _IncomingClanInvitesSection extends StatelessWidget {
  final String userId;

  const _IncomingClanInvitesSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    final clanRepo = context.read<ClanRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          title: 'ПРИГЛАШЕНИЯ В КЛАН',
          icon: Icons.groups_outlined,
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ClanInviteModel>>(
          stream: clanRepo.watchIncomingClanInvites(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const _LoadingHint();
            }
            if (snapshot.hasError) {
              return _ErrorHint(message: snapshot.error.toString());
            }

            final invites = snapshot.data ?? const [];
            if (invites.isEmpty) {
              return const _EmptyHint(text: 'НЕТ ПРИГЛАШЕНИЙ В КЛАН');
            }

            return Column(
              children: [
                for (final invite in invites)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ClanInviteCard(
                      invite: invite,
                      onAccept: () => _handleAccept(context, invite),
                      onReject: () => _handleReject(context, invite),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleAccept(
    BuildContext context,
    ClanInviteModel invite,
  ) async {
    try {
      await context.read<ClanRepository>().acceptClanInvite(
            userId: userId,
            invite: invite,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          content: const Text(
            'ВЫ ВСТУПИЛИ В КЛАН',
            style: TextStyle(
              fontFamily: 'monospace',
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    } catch (err) {
      if (!context.mounted) return;
      CyberSnackBar.showError(
        context,
        err.toString(),
        backgroundColor: AppColors.surfaceCard,
      );
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    ClanInviteModel invite,
  ) async {
    try {
      await context.read<ClanRepository>().rejectClanInvite(
            userId: userId,
            invite: invite,
          );
    } catch (err) {
      if (!context.mounted) return;
      CyberSnackBar.showError(
        context,
        err.toString(),
        backgroundColor: AppColors.surfaceCard,
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderRed),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neonRed, size: 18),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.neonRed,
              fontFamily: 'monospace',
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendRequestCard extends StatelessWidget {
  final FriendRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _FriendRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _AvatarBadge(fileName: request.avatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.senderName.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'ХОЧЕТ ДОБАВИТЬ ВАС В СЕТЬ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberpunkButton(
                  text: 'ПРИНЯТЬ',
                  height: 40,
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CyberpunkButton(
                  text: 'ОТКЛОНИТЬ',
                  height: 40,
                  isOutlined: true,
                  onPressed: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClanInviteCard extends StatelessWidget {
  final ClanInviteModel invite;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ClanInviteCard({
    required this.invite,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _AvatarBadge(fileName: invite.fromAvatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.fromUsername.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      invite.fromEmail,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                    ),
                    const Text(
                      'ПРИГЛАШАЕТ В КЛАН',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CyberpunkButton(
                  text: 'ПРИНЯТЬ',
                  height: 40,
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CyberpunkButton(
                  text: 'ОТКЛОНИТЬ',
                  height: 40,
                  isOutlined: true,
                  onPressed: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String fileName;

  const _AvatarBadge({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neonRed),
      ),
      child: ClipOval(
        child: Image.asset(
          userAvatarAssetPath(fileName),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person,
            color: AppColors.neonRed,
          ),
        ),
      ),
    );
  }
}

class _LoadingHint extends StatelessWidget {
  const _LoadingHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: AppColors.neonRed,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;

  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textDisabled,
          fontFamily: 'monospace',
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ErrorHint extends StatelessWidget {
  final String message;

  const _ErrorHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderRed),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.neonRed,
          fontFamily: 'monospace',
          fontSize: 10,
        ),
      ),
    );
  }
}
