import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_bloc.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class EditIdentityScreen extends StatefulWidget {
  const EditIdentityScreen({super.key});

  @override
  State<EditIdentityScreen> createState() => _EditIdentityScreenState();
}

class _EditIdentityScreenState extends State<EditIdentityScreen> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _emailCtrl;
  late String _selectedAvatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AppAuthBloc>().state;
    final user = auth is AppAuthAuthenticatedState ? auth.user : null;
    _selectedAvatar = resolveUserAvatarFile(user?.avatar);
    _nicknameCtrl = TextEditingController(text: user?.username ?? '');
    final registeredEmail =
        FirebaseAuth.instance.currentUser?.email ?? user?.email ?? '';
    _emailCtrl = TextEditingController(text: registeredEmail);
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = context.read<AppAuthBloc>().state;
    if (auth is! AppAuthAuthenticatedState) return;

    final nickname = _nicknameCtrl.text.trim();
    if (nickname.isEmpty) {
      CyberSnackBar.showError(
        context,
        AppLocalizations.of(context).editIdentityEnterNick,
        backgroundColor: AppColors.neonRedDark,
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<AuthRepository>().updateUserProfile(
        auth.user.uid,
        nickname: nickname,
        avatar: _selectedAvatar,
      );
      if (!mounted) return;
      context.read<AppAuthBloc>().add(AppAuthRefreshProfileEvent());
      try {
        context.read<MapBloc>().add(MapProfileUpdatedEvent(nickname));
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceCard,
          content: Text(AppLocalizations.of(context).editIdentityUpdated),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      CyberSnackBar.showError(
        context,
        l10nByKey(AppLocalizations.of(context), mapFirebaseError(e)),
        backgroundColor: AppColors.neonRedDark,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text(
          l10n.editIdentityTitle,
          style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: kScreenContentPadding.copyWith(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.editIdentityRegisteredEmailLabel,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 10,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailCtrl,
                    readOnly: true,
                    enableInteractiveSelection: true,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceCard.withValues(alpha: 0.45),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.7),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2),
                        borderSide: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.7),
                        ),
                      ),
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.editIdentityNickLabel,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nicknameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.editIdentityNickHint,
                      hintStyle: const TextStyle(color: AppColors.textDisabled),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.editIdentityAvatarLabel,
                    style: const TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 10,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: kUserAvatarFiles.length,
                itemBuilder: (context, index) {
                  final file = kUserAvatarFiles[index];
                  final selected = file == _selectedAvatar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = file),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? AppColors.neonRed : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                  color: AppColors.neonRedGlow,
                                  blurRadius: 12,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              userAvatarAssetPath(file),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.textDisabled,
                                ),
                              ),
                            ),
                            if (selected)
                              const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.neonRed,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: kScreenContentPadding.copyWith(top: 8),
              child: SlcButton(
                text: l10n.commonSave,
                isLoading: _saving,
                onTap: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
