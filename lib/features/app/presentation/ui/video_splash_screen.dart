import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/audio/audio_service.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..setLooping(false)
      ..setVolume(1.0)
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
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller.value.isInitialized)
              _FullScreenVideoCover(controller: _controller)
            else
              const ColoredBox(
                color: AppColors.background,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.neonRed,
                    strokeWidth: 2,
                  ),
                ),
              ),
            Positioned(
              right: 16,
              bottom: 0,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 12),
                child: TextButton(
                  onPressed: () {
                    AudioService.instance.playClick();
                    _goNext();
                  },
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Scales [VideoPlayer] with [BoxFit.cover] to fill the entire screen.
class _FullScreenVideoCover extends StatelessWidget {
  final VideoPlayerController controller;

  const _FullScreenVideoCover({required this.controller});

  @override
  Widget build(BuildContext context) {
    final videoSize = controller.value.size;
    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return const ColoredBox(color: AppColors.background);
    }

    return SizedBox.expand(
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.center,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
