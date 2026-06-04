import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late final VideoPlayerController _controller;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..setLooping(false)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });
    _controller.addListener(_handleVideoProgress);
  }

  void _handleVideoProgress() {
    if (!_controller.value.isInitialized || _navigated) return;
    final position = _controller.value.position;
    final duration = _controller.value.duration;
    if (duration > Duration.zero && position >= duration) {
      _goNext();
    }
  }

  void _goNext() {
    if (!mounted || _navigated) return;
    _navigated = true;
    final authState = context.read<AppAuthBloc>().state;
    if (authState is AppAuthAuthenticatedState) {
      context.go('/map');
      return;
    }
    context.go('/auth');
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.neonRed,
                      strokeWidth: 2,
                    ),
                  ),
          ),
          Positioned(
            right: 16,
            bottom: 20,
            child: TextButton(
              onPressed: _goNext,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF39FF14),
              ),
              child: const Text(
                'SKIP',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(color: Color(0x8039FF14), blurRadius: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
