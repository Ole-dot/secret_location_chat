import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';

class GeolocationScreen extends StatelessWidget {
  const GeolocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'ГЕОЛОКАЦИЯ',
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'ГЕОЛОКАЦИЯ',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'monospace',
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
