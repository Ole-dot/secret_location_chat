import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/data/models/user_model.dart';
import 'package:secret_location_chat/data/user/user_repository.dart';
import 'package:secret_location_chat/features/gifts/gift_store_launch_args.dart';

class SearchUserSheet extends StatefulWidget {
  final bool selectMode;

  const SearchUserSheet({super.key, this.selectMode = false});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchUserSheet(),
    );
  }

  static Future<UserModel?> pick(BuildContext context) {
    return showModalBottomSheet<UserModel?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchUserSheet(selectMode: true),
    );
  }

  @override
  State<SearchUserSheet> createState() => _SearchUserSheetState();
}

class _SearchUserSheetState extends State<SearchUserSheet> {
  final _emailCtrl = TextEditingController();
  bool _isSearching = false;
  UserModel? _foundUser;
  String? _errorMessage;
  bool _notFound = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() {
        _foundUser = null;
        _notFound = false;
        _errorMessage = 'ВВЕДИТЕ EMAIL';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _foundUser = null;
      _notFound = false;
      _errorMessage = null;
    });

    try {
      final user = await context.read<UserRepository>().findUserByEmail(email);
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _foundUser = user;
        _notFound = user == null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _foundUser = null;
        _notFound = false;
        _errorMessage = mapFirebaseError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
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
        child: SingleChildScrollView(
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
              const Text(
                'НАЙТИ ПОЛЬЗОВАТЕЛЯ',
                style: TextStyle(
                  color: AppColors.neonRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '// ПОИСК ПО ТОЧНОМУ EMAIL //',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'EMAIL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'user@example.com',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                ),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 20),
              SlcButton(
                text: 'Искать',
                isLoading: _isSearching,
                onTap: _search,
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.neonRed,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              if (_notFound)
                const Text(
                  'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (_foundUser != null)
                _UserResultCard(
                  user: _foundUser!,
                  selectMode: widget.selectMode,
                  onSendGift: widget.selectMode
                      ? null
                      : () {
                          Navigator.pop(context);
                          context.push(
                            '/gift-store',
                            extra: GiftStoreLaunchArgs(recipient: _foundUser),
                          );
                        },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserResultCard extends StatelessWidget {
  final UserModel user;
  final bool selectMode;
  final VoidCallback? onSendGift;

  const _UserResultCard({
    required this.user,
    this.selectMode = false,
    this.onSendGift,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: selectMode ? () => Navigator.pop(context, user) : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderRed),
              ),
              child: Row(
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
                          const Text(
                            'НАЖМИТЕ, ЧТОБЫ ВЫБРАТЬ',
                            style: TextStyle(
                              color: AppColors.neonRed,
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onSendGift != null) ...[
          const SizedBox(height: 12),
          SlcButton(
            text: 'ОТПРАВИТЬ ПОДАРОК',
            onTap: onSendGift,
          ),
        ],
      ],
    );
  }
}
