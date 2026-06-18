import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/clan_cubit.dart';

class ClanEmailSearchSheet extends StatefulWidget {
  const ClanEmailSearchSheet({super.key});

  static Future<void> show(BuildContext context) {
    context.read<ClanCubit>().clearEmailSearch();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ClanCubit>(),
        child: const ClanEmailSearchSheet(),
      ),
    );
  }

  @override
  State<ClanEmailSearchSheet> createState() => _ClanEmailSearchSheetState();
}

class _ClanEmailSearchSheetState extends State<ClanEmailSearchSheet> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _search() {
    context.read<ClanCubit>().searchByEmail(_emailCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: AppColors.borderRed, width: 2),
              left: BorderSide(color: AppColors.borderRed),
              right: BorderSide(color: AppColors.borderRed),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: BlocListener<ClanCubit, ClanState>(
              listenWhen: (prev, next) =>
                  prev.successMessage != next.successMessage &&
                  next.successMessage == 'MEMBER ADDED TO CLAN',
              listener: (context, _) => Navigator.of(context).pop(),
              child: BlocBuilder<ClanCubit, ClanState>(
              builder: (context, state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'TERMINAL:// SEARCH USER',
                            style: TextStyle(
                              color: AppColors.neonRed,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        '> INVITE MEMBER BY EMAIL — EXACT MATCH QUERY',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 10,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'EMAIL ADDRESS',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'agent@terminal.net',
                        hintStyle: TextStyle(color: AppColors.textDisabled),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                    const SizedBox(height: 12),
                    SlcButton(
                      text: 'SCAN DATABASE',
                      isLoading: state.isEmailSearching,
                      onTap: _search,
                    ),
                    if (state.isEmailSearching) ...[
                      const SizedBox(height: 20),
                      const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.neonRed,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ],
                    if (state.emailSearchNotFound) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'USER NOT FOUND',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace',
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (state.emailSearchUser != null) ...[
                      const SizedBox(height: 20),
                      _EmailSearchResultCard(
                        username: state.emailSearchUser!.username,
                        email: state.emailSearchUser!.email,
                        avatar: state.emailSearchUser!.avatar,
                        alreadyInClan: state.emailTargetInClan,
                        isAdding: state.invitingUserId ==
                            state.emailSearchUser!.uid,
                        onAdd: () => context
                            .read<ClanCubit>()
                            .addMemberByEmail(state.emailSearchUser!),
                      ),
                    ],
                  ],
                );
              },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailSearchResultCard extends StatelessWidget {
  final String username;
  final String email;
  final String avatar;
  final bool alreadyInClan;
  final bool isAdding;
  final VoidCallback onAdd;

  const _EmailSearchResultCard({
    required this.username,
    required this.email,
    required this.avatar,
    required this.alreadyInClan,
    required this.isAdding,
    required this.onAdd,
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
          if (alreadyInClan)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'ALREADY IN A CLAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange,
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            )
          else
            CyberpunkButton(
              text: 'ADD TO CLAN',
              height: 40,
              isLoading: isAdding,
              onPressed: isAdding ? null : onAdd,
            ),
        ],
      ),
    );
  }
}
