import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/data/friends/friends_repository.dart';
import 'package:secret_location_chat/data/models/friendship_status.dart';
import 'package:secret_location_chat/data/models/user_model.dart';
import 'package:secret_location_chat/data/user/user_repository.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/gifts/gift_store_launch_args.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/search_user_cubit.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class SearchUserSheet extends StatefulWidget {
  final bool selectMode;

  const SearchUserSheet({super.key, this.selectMode = false});

  static Future<void> show(BuildContext context) {
    final authState = context.read<AppAuthBloc>().state;
    if (authState is! AppAuthAuthenticatedState) return Future.value();

    final userRepository = context.read<UserRepository>();
    final friendsRepository = context.read<FriendsRepository>();
    final hostContext = Navigator.of(context).context;
    return showModalBottomSheet<void>(
      context: hostContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => SearchUserCubit(
          userRepository: userRepository,
          friendsRepository: friendsRepository,
          currentUser: authState.user,
        ),
        child: const SearchUserSheet(),
      ),
    );
  }

  static Future<UserModel?> pick(BuildContext context) {
    final authState = context.read<AppAuthBloc>().state;
    if (authState is! AppAuthAuthenticatedState) return Future.value();

    final userRepository = context.read<UserRepository>();
    final friendsRepository = context.read<FriendsRepository>();
    final hostContext = Navigator.of(context).context;
    return showModalBottomSheet<UserModel?>(
      context: hostContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => SearchUserCubit(
          userRepository: userRepository,
          friendsRepository: friendsRepository,
          currentUser: authState.user,
        ),
        child: const SearchUserSheet(selectMode: true),
      ),
    );
  }

  @override
  State<SearchUserSheet> createState() => _SearchUserSheetState();
}

class _SearchUserSheetState extends State<SearchUserSheet> {
  final _queryCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _queryCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    context.read<SearchUserCubit>().search(
          _queryCtrl.text,
          emptyQueryHint: l10n.searchEnterQuery,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: Container(
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
          child: BlocConsumer<SearchUserCubit, SearchUserState>(
            listenWhen: (prev, next) =>
                prev.friendActionError != next.friendActionError,
            listener: (context, state) {
              if (state.friendActionError == null) return;
              CyberSnackBar.showError(
                context,
                l10nByKey(l10n, state.friendActionError!),
                backgroundColor: AppColors.surfaceCard,
              );
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.searchTitle,
                      style: const TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.searchSubtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.searchQueryLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _queryCtrl,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: l10n.searchQueryHint,
                        hintStyle:
                            const TextStyle(color: AppColors.textDisabled),
                        suffixIcon: IconButton(
                          tooltip: l10n.searchButton,
                          icon: Icon(
                            Icons.search,
                            color: state.isSearching
                                ? AppColors.textDisabled
                                : AppColors.neonRed,
                          ),
                          onPressed: state.isSearching ? null : _search,
                        ),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                    const SizedBox(height: 20),
                    SlcButton(
                      text: l10n.searchButton,
                      isLoading: state.isSearching,
                      onTap: state.isSearching ? null : _search,
                    ),
                    const SizedBox(height: 20),
                    if (state.emptyQueryMessage != null)
                      Text(
                        state.emptyQueryMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.neonRed,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    if (state.errorMessage != null)
                      Text(
                        l10nByKey(l10n, state.errorMessage!),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.neonRed,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    if (state.notFound)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          border: Border.all(color: AppColors.borderRed),
                        ),
                        child: Text(
                          l10n.searchNotFound,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.neonRed,
                            fontFamily: 'monospace',
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ...state.results.map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _UserResultCard(
                          user: user,
                          selectMode: widget.selectMode,
                          friendshipStatus: state.friendshipFor(user.uid),
                          isSendingRequest:
                              state.isSendingFriendRequest(user.uid),
                          onAddFriend: widget.selectMode
                              ? null
                              : () => context
                                  .read<SearchUserCubit>()
                                  .sendFriendRequest(user),
                          onOpenProfile: widget.selectMode
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  context.push('/user/${user.uid}', extra: user);
                                },
                          onSendGift: widget.selectMode
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  context.push(
                                    '/gift-store',
                                    extra: GiftStoreLaunchArgs(recipient: user),
                                  );
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UserResultCard extends StatelessWidget {
  final UserModel user;
  final bool selectMode;
  final FriendshipStatus friendshipStatus;
  final bool isSendingRequest;
  final VoidCallback? onAddFriend;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onSendGift;

  const _UserResultCard({
    required this.user,
    this.selectMode = false,
    this.friendshipStatus = FriendshipStatus.none,
    this.isSendingRequest = false,
    this.onAddFriend,
    this.onOpenProfile,
    this.onSendGift,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: selectMode
                ? () => Navigator.pop(context, user)
                : onOpenProfile,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderRed),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonRed, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        userAvatarAssetPath(user.avatar),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: AppColors.neonRed,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        if (selectMode) ...[
                          const SizedBox(height: 6),
                          Text(
                            l10n.searchTapToSelect,
                            style: const TextStyle(
                              color: AppColors.neonRed,
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!selectMode) ...[
                    const SizedBox(width: 8),
                    _SearchFriendActionButton(
                      status: friendshipStatus,
                      isLoading: isSendingRequest,
                      onAddFriend: onAddFriend,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!selectMode) ...[
          const SizedBox(height: 12),
          SlcButton(
            text: 'OPEN PROFILE',
            onTap: onOpenProfile,
          ),
        ],
        if (onSendGift != null) ...[
          const SizedBox(height: 12),
          SlcButton(
            text: l10n.searchSendGift,
            onTap: onSendGift,
          ),
        ],
      ],
    );
  }
}

class _SearchFriendActionButton extends StatelessWidget {
  final FriendshipStatus status;
  final bool isLoading;
  final VoidCallback? onAddFriend;

  const _SearchFriendActionButton({
    required this.status,
    required this.isLoading,
    this.onAddFriend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return const SizedBox(
        width: 36,
        height: 36,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.neonRed,
          ),
        ),
      );
    }

    switch (status) {
      case FriendshipStatus.friends:
        return _StatusChip(
          label: l10n.searchAlreadyFriends,
          icon: Icons.link,
          color: AppColors.textSecondary,
        );
      case FriendshipStatus.pendingOutgoing:
        return _StatusChip(
          label: l10n.searchRequestSent,
          icon: Icons.check,
          color: AppColors.neonRed,
        );
      case FriendshipStatus.pendingIncoming:
        return _StatusChip(
          label: l10n.searchIncomingRequest,
          icon: Icons.mail_outline,
          color: AppColors.neonRed,
        );
      case FriendshipStatus.none:
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onAddFriend,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neonRed),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_add_outlined,
                    size: 16,
                    color: AppColors.neonRed,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.searchAddFriend,
                    style: const TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
