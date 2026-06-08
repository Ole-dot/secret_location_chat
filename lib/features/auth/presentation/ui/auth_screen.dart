import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/auth/presentation/bloc/auth_form_bloc.dart';
import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

/// Экран входа — тёмные силуэты, красные акценты
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider<AuthFormBloc>(
      create: (_) => AuthFormBloc(),
      child: BlocListener<AppAuthBloc, AppAuthState>(
        listener: (context, state) {
          if (state is AppAuthAuthenticatedState) {
            context.go('/map');
          } else if (state is AppAuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.neonRedDark,
                content: Text(
                  l10nByKey(l10n, state.message),
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
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

                  // Заголовок
                  Text(
                    l10n.authTitle,
                    style: TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.authSubtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Декоративная линия
                  Container(height: 1, color: AppColors.neonRed),
                  const SizedBox(height: 32),

                  // Email
                  BlocBuilder<AuthFormBloc, AuthFormState>(
                    builder: (context, formState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SlcLabel('EMAIL'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (v) =>
                                context.read<AuthFormBloc>().add(
                                  AuthFormChangedEvent(
                                    email: v,
                                    password: _passwordController.text,
                                  ),
                                ),
                            decoration: const InputDecoration(
                              hintText: 'user@example.com',
                            ),
                          ),
                          if (formState is AuthFormInvalidState &&
                              formState.emailError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                l10nByKey(l10n, formState.emailError!),
                                style: const TextStyle(
                                  color: AppColors.neonRed,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password
                  BlocBuilder<AuthFormBloc, AuthFormState>(
                    builder: (context, formState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SlcLabel(l10n.fieldPassword),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            style: const TextStyle(color: AppColors.textPrimary),
                            obscureText: true,
                            onChanged: (v) =>
                                context.read<AuthFormBloc>().add(
                                  AuthFormChangedEvent(
                                    email: _emailController.text,
                                    password: v,
                                  ),
                                ),
                            decoration: const InputDecoration(
                              hintText: '••••••',
                            ),
                          ),
                          if (formState is AuthFormInvalidState &&
                              formState.passwordError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                l10nByKey(l10n, formState.passwordError!),
                                style: const TextStyle(
                                  color: AppColors.neonRed,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Кнопка входа
                  BlocBuilder<AppAuthBloc, AppAuthState>(
                    builder: (context, state) {
                      return SlcButton(
                        text: l10n.authLoginButton,
                        isLoading: state is AppAuthLoadingState,
                        onTap: () {
                          context.read<AppAuthBloc>().add(
                            AppAuthLoginEvent(
                              _emailController.text.trim(),
                              _passwordController.text,
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/reset-password'),
                      child: Text(
                        l10n.authForgotPassword,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Регистрация
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        l10n.authToRegister,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/splash'),
                      child: Text(
                        l10n.commonBack,
                        style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 12,
                        ),
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

class _SlcLabel extends StatelessWidget {
  final String text;
  const _SlcLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 10,
        letterSpacing: 3,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
