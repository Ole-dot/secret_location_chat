import 'package:flutter/material.dart';
import 'package:secret_location_chat/core/audio/audio_service.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';

/// SnackBars with cyberpunk UI sound feedback.
class CyberSnackBar {
  CyberSnackBar._();

  static void showError(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    AudioService.instance.playError();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            backgroundColor ?? AppColors.neonRed.withValues(alpha: 0.92),
        duration: duration,
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: backgroundColor == AppColors.surfaceCard
                ? AppColors.neonRed
                : AppColors.white,
          ),
        ),
      ),
    );
  }
}
