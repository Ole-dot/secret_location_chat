import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/data/models/clan_chat_room.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/clan_cubit.dart';

// RESTORE: shared target, email invite, member roster
// import 'package:secret_location_chat/data/models/clan_member.dart';
// import 'package:secret_location_chat/core/widgets/terminal_confirm_dialog.dart';
// import 'package:secret_location_chat/features/profile/presentation/ui/clan_email_search_sheet.dart';

class ClanScreen extends StatefulWidget {
  const ClanScreen({super.key});

  @override
  State<ClanScreen> createState() => _ClanScreenState();
}

class _ClanScreenState extends State<ClanScreen> {
  final _nicknameCtrl = TextEditingController();

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  void _searchParticipants() {
    context.read<ClanCubit>().searchByNickname(_nicknameCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClanCubit, ClanState>(
      listenWhen: (prev, next) =>
          prev.successMessage != next.successMessage ||
          prev.error != next.error ||
          prev.clanJustCreated != next.clanJustCreated,
      listener: (context, state) {
        if (state.clanJustCreated) {
          context.read<ClanCubit>().acknowledgeClanCreated();
        }
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
        if (state.isBootstrapping) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.neonRed,
                strokeWidth: 2,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: const Text(
              'МОЙ КЛАН',
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
                const _ClanSectionHeader(
                  title: 'КАНАЛЫ КЛАНА',
                  subtitle: 'GENERAL · TACTICS · OPS',
                ),
                const SizedBox(height: 12),
                if (state.chats.isEmpty)
                  const _ClanEmptyHint(text: 'КАНАЛЫ НЕ НАЙДЕНЫ')
                else
                  ...state.chats.map(
                    (chat) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ClanChatChannelTile(chat: chat),
                    ),
                  ),
                const SizedBox(height: 32),
                const _ClanSectionHeader(
                  title: 'ПОИСК УЧАСТНИКОВ',
                  subtitle: 'НИКНЕЙМ ИЛИ ПРЕФИКС EMAIL',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nicknameCtrl,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Никнейм (первые буквы)...',
                    hintStyle: TextStyle(color: AppColors.textDisabled),
                  ),
                  onSubmitted: (_) => _searchParticipants(),
                ),
                const SizedBox(height: 12),
                SlcButton(
                  text: 'ИСКАТЬ',
                  isLoading: state.isSearching,
                  onTap: _searchParticipants,
                ),
                if (state.notFound) ...[
                  const SizedBox(height: 16),
                  const _ClanEmptyHint(text: 'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН'),
                ],
                ...state.searchResults.map(
                  (user) => Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _FoundUserCard(
                      username: user.username,
                      email: user.email,
                      avatar: user.avatar,
                      isInviting: state.invitingUserId == user.uid,
                      onInvite: () =>
                          context.read<ClanCubit>().inviteUser(user),
                    ),
                  ),
                ),

                // ─── RESTORE: removed sections (uncomment imports above) ───
                //
                // const SizedBox(height: 12),
                // Container(
                //   padding: const EdgeInsets.all(12),
                //   decoration: BoxDecoration(
                //     color: AppColors.surfaceCard,
                //     border: Border.all(color: AppColors.borderRed),
                //   ),
                //   child: const Text(
                //     'ТЕРМИНАЛ:// ПОИСК ПО ПРЕФИКСУ НИКА',
                //     style: TextStyle(
                //       color: AppColors.textSecondary,
                //       fontFamily: 'monospace',
                //       letterSpacing: 1.2,
                //       fontSize: 11,
                //     ),
                //   ),
                // ),
                //
                // CyberpunkButton(
                //   text: 'ОБЩАЯ ЦЕЛЬ',
                //   height: 42,
                //   onPressed: () => context.push('/clan/set-target'),
                // ),
                //
                // CyberpunkButton(
                //   text: 'INVITE BY EMAIL',
                //   height: 42,
                //   onPressed: () => ClanEmailSearchSheet.show(context),
                // ),
                //
                // const SizedBox(height: 24),
                // const Text('СОСТАВ КЛАНА', ...),
                // ...state.members.map((member) => _ClanMemberTile(...)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClanSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ClanSectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClanEmptyHint extends StatelessWidget {
  final String text;

  const _ClanEmptyHint({required this.text});

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

class _ClanChatChannelTile extends StatelessWidget {
  final ClanChatRoom chat;

  const _ClanChatChannelTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final encodedName = Uri.encodeComponent(chat.name);
          context.push('/clan/chat/${chat.id}?name=$encodedName');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border.all(color: AppColors.borderRed),
          ),
          child: Row(
            children: [
              const Icon(Icons.tag, color: AppColors.neonRed, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chat.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoundUserCard extends StatelessWidget {
  final String username;
  final String email;
  final String avatar;
  final bool isInviting;
  final VoidCallback onInvite;

  const _FoundUserCard({
    required this.username,
    required this.email,
    required this.avatar,
    required this.isInviting,
    required this.onInvite,
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
              Container(
                width: 44,
                height: 44,
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
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      email,
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
          CyberpunkButton(
            text: 'В КЛАН',
            height: 40,
            isLoading: isInviting,
            onPressed: isInviting ? null : onInvite,
          ),
        ],
      ),
    );
  }
}

// ─── RESTORE: clan member roster tile ───────────────────────────────────────
//
// class _ClanMemberTile extends StatelessWidget {
//   final ClanMember member;
//   final bool showKick;
//   final bool isKicking;
//   final VoidCallback? onKick;
//
//   const _ClanMemberTile({
//     required this.member,
//     this.showKick = false,
//     this.isKicking = false,
//     this.onKick,
//   });
//
//   Color get _statusColor {
//     return switch (member.status) {
//       'active' => const Color(0xFF39FF14),
//       'pending' => Colors.orange,
//       _ => AppColors.textSecondary,
//     };
//   }
//
//   String get _statusLabel {
//     return switch (member.status) {
//       'active' => 'АКТИВ',
//       'pending' => 'ОЖИДАНИЕ',
//       'rejected' => 'ОТКЛОНЁН',
//       _ => member.status.toUpperCase(),
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceCard,
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColors.borderRed),
//             ),
//             child: ClipOval(
//               child: Image.asset(
//                 userAvatarAssetPath(member.avatar),
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) => const Icon(
//                   Icons.person,
//                   color: AppColors.neonRed,
//                   size: 20,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   member.username.toUpperCase(),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: AppColors.textPrimary,
//                     fontFamily: 'monospace',
//                     fontWeight: FontWeight.w700,
//                     fontSize: 11,
//                     letterSpacing: 1.1,
//                   ),
//                 ),
//                 Text(
//                   member.email,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: AppColors.textSecondary,
//                     fontFamily: 'monospace',
//                     fontSize: 10,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             _statusLabel,
//             style: TextStyle(
//               color: _statusColor,
//               fontFamily: 'monospace',
//               fontSize: 9,
//               fontWeight: FontWeight.w800,
//               letterSpacing: 1,
//             ),
//           ),
//           if (showKick && onKick != null) ...[
//             const SizedBox(width: 8),
//             TextButton(
//               onPressed: isKicking ? null : onKick,
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 minimumSize: Size.zero,
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               child: isKicking
//                   ? const SizedBox(
//                       width: 14,
//                       height: 14,
//                       child: CircularProgressIndicator(
//                         color: AppColors.neonRed,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Text(
//                       'ИЗГНАТЬ',
//                       style: TextStyle(
//                         color: AppColors.neonRed,
//                         fontFamily: 'monospace',
//                         fontSize: 9,
//                         fontWeight: FontWeight.w900,
//                         letterSpacing: 1,
//                       ),
//                     ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
