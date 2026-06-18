import 'package:flutter/material.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class CyberVolumeControl extends StatefulWidget {
  final double initialVolume;

  const CyberVolumeControl({
    super.key,
    this.initialVolume = 0.5,
  });

  @override
  State<CyberVolumeControl> createState() => _CyberVolumeControlState();
}

class _CyberVolumeControlState extends State<CyberVolumeControl>
    with TickerProviderStateMixin {
  static const _bulletCount = 12;
  static const _neonBullet = Color(0xFF00E5FF);

  late final AnimationController _speakerController;
  late final AnimationController _staggerController;
  late final Animation<double> _speakerScale;

  double _volume = 0.5;
  int _litBullets = 6;

  @override
  void initState() {
    super.initState();
    _volume = widget.initialVolume.clamp(0.0, 1.0);
    _litBullets = _bulletsForVolume(_volume);

    _speakerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _speakerScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.92), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _speakerController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _speakerController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  int _bulletsForVolume(double volume) {
    if (volume <= 0) return 0;
    if (volume >= 1) return _bulletCount;
    return (volume * _bulletCount).round().clamp(0, _bulletCount);
  }

  void _applyVolume(double volume) {
    final next = volume.clamp(0.0, 1.0);
    if ((next - _volume).abs() < 0.001) return;

    setState(() {
      _volume = next;
      _litBullets = _bulletsForVolume(next);
    });

    _speakerController.forward(from: 0);
    _staggerController.forward(from: 0);
  }

  void _updateFromLocalX(double localX, double width) {
    if (width <= 0) return;
    _applyVolume(localX / width);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderRed),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.volumeLabel,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AnimatedBuilder(
                animation: _speakerController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _speakerScale.value,
                    child: Transform.translate(
                      offset: Offset(_speakerRecoilOffset(), 0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: _neonBullet.withValues(alpha: 0.6)),
                    color: AppColors.surface,
                  ),
                  child: Icon(
                    _volume == 0 ? Icons.volume_off : Icons.volume_up,
                    color: _litBullets > 0 ? _neonBullet : AppColors.textDisabled,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        _updateFromLocalX(
                          details.localPosition.dx,
                          constraints.maxWidth,
                        );
                      },
                      onHorizontalDragUpdate: (details) {
                        _updateFromLocalX(
                          details.localPosition.dx,
                          constraints.maxWidth,
                        );
                      },
                      child: SizedBox(
                        height: 36,
                        child: AnimatedBuilder(
                          animation: _staggerController,
                          builder: (context, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(_bulletCount, (index) {
                                return _VolumeBullet(
                                  lit: index < _litBullets,
                                  progress: _bulletProgress(index),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'УР. ${(_volume * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _neonBullet,
              fontFamily: 'monospace',
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  double _speakerRecoilOffset() {
    if (!_speakerController.isAnimating) return 0;
    return -4 * (1 - _speakerController.value);
  }

  double _bulletProgress(int index) {
    if (index >= _litBullets) return 0;
    final delay = index * 0.07;
    final span = 1.0 - delay;
    if (span <= 0) return 1;
    final t = ((_staggerController.value - delay) / span).clamp(0.0, 1.0);
    return Curves.easeOut.transform(t);
  }
}

class _VolumeBullet extends StatelessWidget {
  final bool lit;
  final double progress;

  const _VolumeBullet({
    required this.lit,
    required this.progress,
  });

  static const _neonBullet = Color(0xFF00E5FF);
  static const _neonGlow = Color(0x8800E5FF);

  @override
  Widget build(BuildContext context) {
    final active = lit && progress > 0;
    final scale = active ? 0.75 + 0.25 * progress : 1.0;
    final opacity = lit ? 0.35 + 0.65 * progress : 1.0;

    return Transform.scale(
      scale: scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? _neonBullet.withValues(alpha: opacity)
              : AppColors.textDisabled.withValues(alpha: 0.35),
          border: Border.all(
            color: active ? _neonBullet : AppColors.border,
            width: 1.2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _neonGlow.withValues(alpha: opacity),
                    blurRadius: 8 + 6 * progress,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
