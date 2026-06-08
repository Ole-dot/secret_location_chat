import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_bloc.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/profile_logout_dialog.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/search_user_sheet.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

/// Киберпанк-меню профиля (modal bottom sheet).
class ProfileMenuSheet extends StatelessWidget {
  final String nickname;
  final String avatarFileName;
  final MapBloc mapBloc;

  const ProfileMenuSheet({
    super.key,
    required this.nickname,
    required this.avatarFileName,
    required this.mapBloc,
  });

  static Future<void> show(
    BuildContext context, {
    required String nickname,
    required String avatarFileName,
    required MapBloc mapBloc,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileMenuSheet(
        nickname: nickname,
        avatarFileName: avatarFileName,
        mapBloc: mapBloc,
      ),
    );
  }

  String get _nicknameUpper => nickname.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neonRed, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.neonRedGlow,
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _AvatarPreview(fileName: avatarFileName),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _nicknameUpper,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.menuHeader,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, color: AppColors.borderRed),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.terminal,
                      label: 'TERMINAL HACK',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/minigame');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.diamond_outlined,
                      label: 'STONES',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/stones-store');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.card_giftcard_outlined,
                      label: 'GIFT STORE',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/gift-store');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.person_search_outlined,
                      label: l10n.menuFindUser,
                      onTap: () {
                        Navigator.pop(context);
                        SearchUserSheet.show(context);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.face_retouching_natural,
                      label: l10n.menuChangeIdentity,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/edit-identity', extra: mapBloc);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.workspace_premium_outlined,
                      label: l10n.menuChangePlan,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/plan', extra: mapBloc);
                      },
                    ),
                    _MenuItem(
                      icon: Icons.offline_bolt_outlined,
                      label: l10n.menuOfflineMaps,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/offline-maps');
                      },
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      label: l10n.menuSettings,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/settings');
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.logout,
                      label: l10n.menuLogout,
                      labelColor: AppColors.neonRed,
                      onTap: () {
                        Navigator.pop(context);
                        showProfileLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final String fileName;

  const _AvatarPreview({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neonRed, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.neonRedGlow, blurRadius: 12),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          userAvatarAssetPath(fileName),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.pets,
            color: AppColors.neonRed,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: AppColors.neonRed, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor ?? AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textDisabled,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
