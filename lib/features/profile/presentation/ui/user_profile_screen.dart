import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/core/widgets/terminal_confirm_dialog.dart';
import 'package:secret_location_chat/data/models/friendship_status.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/user_profile_cubit.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listenWhen: (prev, next) =>
          prev.successMessage != next.successMessage ||
          prev.error != next.error,
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceCard,
              content: Text(
                state.successMessage!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          );
        }
        if (state.error != null) {
          CyberSnackBar.showError(
            context,
            state.error!,
            backgroundColor: AppColors.surfaceCard,
          );
        }
      },
      builder: (context, state) {
        final user = state.targetUser;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: const Text(
              'USER PROFILE',
              style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => context.pop(),
            ),
          ),
          body: ScreenScrollBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    border: Border.all(color: AppColors.borderRed),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.neonRed, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            userAvatarAssetPath(user.avatar),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: AppColors.neonRed,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _FriendshipAction(
                  status: state.friendshipStatus,
                  isLoading: state.isActionInProgress,
                  onAddFriend: () =>
                      context.read<UserProfileCubit>().addFriend(),
                  onAccept: () =>
                      context.read<UserProfileCubit>().acceptFriend(),
                  onDisconnect: () async {
                    final confirmed = await showTerminalConfirmDialog(
                      context,
                      title: 'TERMINATE CONNECTION?',
                      message:
                          'УДАЛИТЬ ${user.username.toUpperCase()} ИЗ СЕТИ? ЭТО ДЕЙСТВИЕ НЕЛЬЗЯ ОТМЕНИТЬ.',
                      confirmLabel: 'УДАЛИТЬ ИЗ СЕТИ',
                    );
                    if (!context.mounted || !confirmed) return;
                    await context.read<UserProfileCubit>().removeFriend();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FriendshipAction extends StatelessWidget {
  final FriendshipStatus status;
  final bool isLoading;
  final VoidCallback onAddFriend;
  final VoidCallback onAccept;
  final VoidCallback onDisconnect;

  const _FriendshipAction({
    required this.status,
    required this.isLoading,
    required this.onAddFriend,
    required this.onAccept,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      FriendshipStatus.friends => _DisconnectButton(
          isLoading: isLoading,
          onPressed: onDisconnect,
        ),
      FriendshipStatus.pendingOutgoing => Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            'REQUEST PENDING',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.orange,
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
      FriendshipStatus.pendingIncoming => SlcButton(
          text: 'ПРИНЯТЬ ЗАПРОС',
          isLoading: isLoading,
          onTap: onAccept,
        ),
      FriendshipStatus.none => CyberpunkButton(
          text: 'ADD FRIEND',
          height: 48,
          isLoading: isLoading,
          onPressed: isLoading ? null : onAddFriend,
        ),
    };
  }
}

class _DisconnectButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _DisconnectButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1A0808),
            border: Border.all(color: AppColors.neonRed, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44FF0033),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.neonRed,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'УДАЛИТЬ ИЗ СЕТИ',
                  style: TextStyle(
                    color: AppColors.neonRed,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
        ),
      ),
    );
  }
}
