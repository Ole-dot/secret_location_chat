import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

Future<void> showProfileLogoutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx);
      return AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.neonRed, width: 1.5),
        ),
        title: Text(
          l10n.logoutTitle,
          style: const TextStyle(
            color: AppColors.neonRed,
            letterSpacing: 4,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 1,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.commonCancel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                letterSpacing: 2,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppAuthBloc>().add(AppAuthLogoutEvent());
            },
            child: Text(
              l10n.logoutButton,
              style: const TextStyle(
                color: AppColors.neonRed,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      );
    },
  );
}
