import 'package:flutter/material.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';

Future<bool> showTerminalConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'ОТМЕНА',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF0A0A0A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.neonRed, width: 1.5),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.neonRed,
          fontFamily: 'monospace',
          fontSize: 12,
          letterSpacing: 2,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'monospace',
          fontSize: 10,
          letterSpacing: 1.2,
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            cancelLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: const TextStyle(
              color: AppColors.neonRed,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
