import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/data/clan/clan_repository.dart';
import 'package:secret_location_chat/data/friends/friends_repository.dart';
import 'package:secret_location_chat/data/models/clan_invite_model.dart';
import 'package:secret_location_chat/data/models/friend_request_model.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

enum _NetworkRequestKind { friend, clan }

class _NetworkRequestItem {
  final _NetworkRequestKind kind;
  final FriendRequestModel? friendRequest;
  final ClanInviteModel? clanInvite;

  const _NetworkRequestItem.friend(this.friendRequest)
      : kind = _NetworkRequestKind.friend,
        clanInvite = null;

  const _NetworkRequestItem.clan(this.clanInvite)
      : kind = _NetworkRequestKind.clan,
        friendRequest = null;
}

/// Realtime incoming friend + clan requests for the map events sheet.
class NetworkRequestsTabSliver extends StatelessWidget {
  final String userId;

  const NetworkRequestsTabSliver({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final friendsRepo = context.read<FriendsRepository>();
    final clanRepo = context.read<ClanRepository>();
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<FriendRequestModel>>(
      stream: friendsRepo.watchIncomingFriendRequests(userId),
      builder: (context, friendSnapshot) {
        return StreamBuilder<List<ClanInviteModel>>(
          stream: clanRepo.watchIncomingClanInvites(userId),
          builder: (context, clanSnapshot) {
            if (friendSnapshot.hasError) {
              return SliverToBoxAdapter(
                child: _NetworkErrorPanel(
                  message: friendSnapshot.error.toString(),
                ),
              );
            }
            if (clanSnapshot.hasError) {
              return SliverToBoxAdapter(
                child: _NetworkErrorPanel(
                  message: clanSnapshot.error.toString(),
                ),
              );
            }

            final waiting = (friendSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !friendSnapshot.hasData) ||
                (clanSnapshot.connectionState == ConnectionState.waiting &&
                    !clanSnapshot.hasData);

            if (waiting) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonRed,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final items = <_NetworkRequestItem>[
              ...?friendSnapshot.data?.map(_NetworkRequestItem.friend),
              ...?clanSnapshot.data?.map(_NetworkRequestItem.clan),
            ];

            if (items.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: NetworkRequestsEmptyPanel(label: l10n.eventsNetworkEmpty),
              );
            }

            final bottomPadding = 16.0 + systemBottomInset(context);

            return SliverPadding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPadding),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return switch (item.kind) {
                    _NetworkRequestKind.friend => _FriendRequestRow(
                        request: item.friendRequest!,
                        onAccept: () => _acceptFriend(
                          context,
                          item.friendRequest!,
                        ),
                        onDecline: () => _declineFriend(
                          context,
                          item.friendRequest!,
                        ),
                      ),
                    _NetworkRequestKind.clan => _ClanInviteRow(
                        invite: item.clanInvite!,
                        onAccept: () => _acceptClan(
                          context,
                          item.clanInvite!,
                        ),
                        onDecline: () => _declineClan(
                          context,
                          item.clanInvite!,
                        ),
                      ),
                  };
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _acceptFriend(
    BuildContext context,
    FriendRequestModel request,
  ) async {
    try {
      await context.read<FriendsRepository>().acceptFriendRequest(
            currentUserId: userId,
            otherUserId: request.senderId,
            requestId: request.requestId,
          );
    } catch (err) {
      if (!context.mounted) return;
      CyberSnackBar.showError(context, err.toString());
    }
  }

  Future<void> _declineFriend(
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
      CyberSnackBar.showError(context, err.toString());
    }
  }

  Future<void> _acceptClan(
    BuildContext context,
    ClanInviteModel invite,
  ) async {
    try {
      await context.read<ClanRepository>().acceptClanInvite(
            userId: userId,
            invite: invite,
          );
    } catch (err) {
      if (!context.mounted) return;
      CyberSnackBar.showError(context, err.toString());
    }
  }

  Future<void> _declineClan(
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
      CyberSnackBar.showError(context, err.toString());
    }
  }
}

class _FriendRequestRow extends StatelessWidget {
  final FriendRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _FriendRequestRow({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return _NetworkRequestCard(
      avatar: request.avatar,
      title: request.senderName.toUpperCase(),
      subtitle: 'UID: ${request.senderId}',
      badge: 'FRIEND REQUEST',
      onAccept: onAccept,
      onDecline: onDecline,
    );
  }
}

class _ClanInviteRow extends StatelessWidget {
  final ClanInviteModel invite;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _ClanInviteRow({
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return _NetworkRequestCard(
      avatar: invite.fromAvatar,
      title: invite.fromUsername.toUpperCase(),
      subtitle: invite.fromEmail,
      badge: 'CLAN INVITE',
      onAccept: onAccept,
      onDecline: onDecline,
    );
  }
}

class _NetworkRequestCard extends StatelessWidget {
  final String avatar;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _NetworkRequestCard({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonRed),
                ),
                child: ClipOval(
                  child: Image.asset(
                    userAvatarAssetPath(avatar),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      color: AppColors.neonRed,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge,
                      style: const TextStyle(
                        color: AppColors.neonRed,
                        fontFamily: 'monospace',
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 10,
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
                child: _NetworkActionButton(
                  label: 'ACCEPT',
                  color: const Color(0xFF39FF14),
                  onPressed: onAccept,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NetworkActionButton(
                  label: 'DECLINE',
                  color: AppColors.neonRed,
                  onPressed: onDecline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _NetworkActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class NetworkRequestsEmptyPanel extends StatelessWidget {
  final String label;

  const NetworkRequestsEmptyPanel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hub_outlined,
            color: AppColors.textDisabled.withValues(alpha: 0.8),
            size: 30,
          ),
          const SizedBox(height: 14),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDisabled,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkErrorPanel extends StatelessWidget {
  final String message;

  const _NetworkErrorPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: SelectableText(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.neonRed,
          fontFamily: 'monospace',
          fontSize: 10,
          height: 1.4,
        ),
      ),
    );
  }
}
