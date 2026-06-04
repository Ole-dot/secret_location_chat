import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';

Future<void> showProfileLogoutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.neonRed, width: 1.5),
      ),
      title: const Text(
        'ВЫХОД',
        style: TextStyle(
          color: AppColors.neonRed,
          letterSpacing: 4,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: const Text(
        'ЗАВЕРШИТЬ СЕАНС И ВЫЙТИ ИЗ АККАУНТА?',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          letterSpacing: 1,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'ОТМЕНА',
            style: TextStyle(color: AppColors.textSecondary, letterSpacing: 2),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.read<AppAuthBloc>().add(AppAuthLogoutEvent());
          },
          child: const Text(
            'ВЫЙТИ',
            style: TextStyle(
              color: AppColors.neonRed,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    ),
  );
}
