import 'package:flutter/material.dart';
import 'package:secret_location_chat/core/audio/audio_service.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
/// Uniform send control for all chat / message input bars.
class ChatSendIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const ChatSendIconButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return IconButton(
      onPressed: enabled
          ? () {
              AudioService.instance.playSend();
              onPressed!();
            }
          : null,
      icon: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.neonRed,
              ),
            )
          : Icon(
              Icons.send_rounded,
              color: enabled ? AppColors.neonRed : AppColors.textDisabled,
            ),
    );
  }
}
