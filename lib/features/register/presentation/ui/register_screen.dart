import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';
import 'package:secret_location_chat/features/register/presentation/bloc/register_bloc.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _usernameCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _usernameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => RegisterBloc(context.read<AuthRepository>()),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccessState) {
            context.go('/map');
          } else if (state is RegisterErrorState) {
            CyberSnackBar.showError(
              context,
              l10nByKey(l10n, state.message),
              backgroundColor: AppColors.neonRedDark,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    l10n.registerTitle,
                    style: const TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.registerSubtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2),
                  ),
                  const SizedBox(height: 48),
                  Container(height: 1, color: AppColors.neonRed),
                  const SizedBox(height: 32),

                  _Label(l10n.registerNickLabel),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _usernameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n.registerNickHint,
                      hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.registerNickNote,
                    style: const TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 1),
                  ),
                  const SizedBox(height: 20),

                  _Label('EMAIL'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'user@example.com'),
                  ),
                  const SizedBox(height: 20),

                  _Label(l10n.fieldPassword),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    obscureText: true,
                    decoration: const InputDecoration(hintText: '••••••'),
                  ),
                  const SizedBox(height: 40),

                  BlocBuilder<RegisterBloc, RegisterState>(
                    builder: (context, state) => SlcButton(
                      text: l10n.registerButton,
                      isLoading: state is RegisterLoadingState,
                      onTap: () {
                        context.read<RegisterBloc>().add(
                          RegisterSubmitEvent(
                            email: _emailCtrl.text.trim(),
                            password: _passwordCtrl.text,
                            username: _usernameCtrl.text.trim(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/reset-password'),
                      child: Text(
                        l10n.authForgotPassword,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/auth'),
                      child: Text(
                        l10n.registerHaveAccount,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w600),
  );
}
