import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Главная кнопка в стиле Cyberpunk/Y2K
class SlcButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;

  const SlcButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isOutlined ? AppColors.transparent : AppColors.neonRed,
          border: Border.all(
            color: AppColors.neonRed,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(2),
          boxShadow: onTap != null && !isOutlined
              ? [
                  BoxShadow(
                    color: AppColors.neonRedGlow,
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(
                text.toUpperCase(),
                style: TextStyle(
                  color: isOutlined ? AppColors.neonRed : AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 3,
                ),
              ),
      ),
    );
  }
}
