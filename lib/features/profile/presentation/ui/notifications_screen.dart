import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/widgets/cyber_radar_slider.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/widgets/cyber_volume_control.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'УВЕДОМЛЕНИЯ',
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CyberVolumeControl(),
            SizedBox(height: 24),
            CyberRadarSlider(),
            SizedBox(height: 20),
            Text(
              '// TAP OR DRAG THE TRACK TO ADJUST //',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
