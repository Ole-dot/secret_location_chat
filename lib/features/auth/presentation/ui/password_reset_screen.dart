import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/auth/firebase_auth_language.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';
import 'package:secret_location_chat/features/auth/presentation/bloc/password_reset_bloc.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  late final TextEditingController _emailController;
  late String _firebaseLanguageCode;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _firebaseLanguageCode = resolveFirebaseAuthLanguageCode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasswordResetBloc(context.read<AuthRepository>()),
      child: BlocConsumer<PasswordResetBloc, PasswordResetState>(
        listener: (context, state) {
          if (state is PasswordResetSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.surfaceCard,
                content: Text(
                  'Ссылка для сброса пароля отправлена на email',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
            );
          } else if (state is PasswordResetErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.neonRedDark,
                content: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    const Text(
                      'СБРОС',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '// ВОССТАНОВЛЕНИЕ ДОСТУПА //',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Container(height: 1, color: AppColors.neonRed),
                    const SizedBox(height: 32),
                    const _SlcLabel('EMAIL'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'user@example.com',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SlcLabel('ЯЗЫК ПИСЬМА'),
                    const SizedBox(height: 8),
                    _LanguageSelector(
                      value: _firebaseLanguageCode,
                      onChanged: (code) =>
                          setState(() => _firebaseLanguageCode = code),
                    ),
                    const SizedBox(height: 32),
                    SlcButton(
                      text: 'Отправить ссылку',
                      isLoading: state is PasswordResetLoadingState,
                      onTap: () {
                        context.read<PasswordResetBloc>().add(
                          PasswordResetSubmitEvent(
                            _emailController.text,
                            languageCode: _firebaseLanguageCode,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.go('/auth'),
                        child: const Text(
                          '← Назад ко входу',
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
          );
        },
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final deviceLang =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    final deviceHint = deviceLang == 'kk' || deviceLang == 'kz'
        ? ' (язык устройства: ҚАЗ)'
        : ' (язык устройства: РУС)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LangChip(
              label: 'РУС',
              selected: value == firebaseAuthLanguageRu,
              onTap: () => onChanged(firebaseAuthLanguageRu),
            ),
            const SizedBox(width: 12),
            _LangChip(
              label: 'ҚАЗ',
              selected: value == firebaseAuthLanguageKk,
              onTap: () => onChanged(firebaseAuthLanguageKk),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          deviceHint,
          style: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonRed.withValues(alpha: 0.15)
              : AppColors.transparent,
          border: Border.all(
            color: selected ? AppColors.neonRed : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.neonRed : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
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
