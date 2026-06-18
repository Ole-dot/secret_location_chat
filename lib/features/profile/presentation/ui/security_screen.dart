import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/security_cubit.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SecurityCubit, SecurityState>(
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
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: const Text(
              'Секьюрити',
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    border: Border.all(color: AppColors.borderRed),
                  ),
                  child: const Text(
                    'ТЕРМИНАЛ:// ПРОТОКОЛЫ БЕЗОПАСНОСТИ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                      letterSpacing: 1.3,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CyberpunkButton(
                  text: 'СМЕНИТЬ ПАРОЛЬ',
                  isOutlined: true,
                  isLoading: state.isSendingReset,
                  onPressed: state.isSendingReset
                      ? null
                      : () => context.read<SecurityCubit>().sendPasswordReset(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'САМОУНИЧТОЖЕНИЕ',
                  style: TextStyle(
                    color: AppColors.neonRed,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'БЕЗВОЗВРАТНО УДАЛЯЕТ ДАННЫЕ АККАУНТА ИЗ FIRESTORE И FIREBASE AUTH.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 1,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                CyberpunkButton(
                  text: 'ЗАПУСТИТЬ САМОУНИЧТОЖЕНИЕ',
                  isLoading: state.isDeleting,
                  onPressed: state.isDeleting
                      ? null
                      : () => _showSelfDestructDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSelfDestructDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SelfDestructCountdownDialog(),
    );
    if (confirmed != true || !context.mounted) return;

    final result =
        await context.read<SecurityCubit>().executeSelfDestruct();
    if (!context.mounted) return;

    switch (result) {
      case SelfDestructResult.success:
        final authBloc = context.read<AppAuthBloc>();
        authBloc.add(AppAuthAccountDeletedEvent());
        await authBloc.stream.firstWhere(
          (state) => state is AppAuthUnauthenticatedState,
        );
        if (!context.mounted) return;
        context.go('/auth');
      case SelfDestructResult.requiresRecentLogin:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.surfaceCard,
            duration: Duration(seconds: 6),
            content: Text(
              'SECURITY OVERRIDE: Please log out and log in again to verify '
              'identity before self-destruction.',
              style: TextStyle(
                color: AppColors.neonRed,
                fontFamily: 'monospace',
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        );
      case SelfDestructResult.failed:
        break;
    }
  }
}

class _SelfDestructCountdownDialog extends StatefulWidget {
  const _SelfDestructCountdownDialog();

  @override
  State<_SelfDestructCountdownDialog> createState() =>
      _SelfDestructCountdownDialogState();
}

class _SelfDestructCountdownDialogState
    extends State<_SelfDestructCountdownDialog> {
  int _seconds = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
      setState(() => _seconds -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.neonRed, width: 1.5),
      ),
      title: const Text(
        'САМОУНИЧТОЖЕНИЕ АКТИВИРОВАНО',
        style: TextStyle(
          color: AppColors.neonRed,
          fontFamily: 'monospace',
          letterSpacing: 2,
          fontWeight: FontWeight.w900,
          fontSize: 13,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_seconds',
            style: const TextStyle(
              color: AppColors.neonRed,
              fontFamily: 'monospace',
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'УДАЛЕНИЕ АККАУНТА...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'ОТМЕНА',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
