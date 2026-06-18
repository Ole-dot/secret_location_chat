import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';

class _RadarBlip {
  final double angle;
  final double distance;

  double glow = 0.0;

  _RadarBlip({
    required this.angle,
    required this.distance,
  });
}

class CyberRadarSlider extends StatefulWidget {
  const CyberRadarSlider({super.key});

  @override
  State<CyberRadarSlider> createState() => _CyberRadarSliderState();
}

class _CyberRadarSliderState extends State<CyberRadarSlider>
    with SingleTickerProviderStateMixin {
  static const _minRadius = 1.0;
  static const _maxRadius = 50.0;
  static const _neonCyan = Color(0xFF00E5FF);
  static const _matrixGreen = Color(0xFF39FF14);

  late final AnimationController _sweepController;
  late final List<_RadarBlip> _allBlips;

  double _radius = 15;

  @override
  void initState() {
    super.initState();
    _allBlips = _generateBlips(24);
    _sweepController = AnimationController(
      vsync: this,
      duration: _durationForRadius(_radius),
    )..addListener(_updateBlipGlow)
      ..repeat();
  }

  @override
  void dispose() {
    _sweepController.removeListener(_updateBlipGlow);
    _sweepController.dispose();
    super.dispose();
  }

  List<_RadarBlip> _generateBlips(int count) {
    final random = math.Random(42);
    return List.generate(count, (_) {
      return _RadarBlip(
        angle: random.nextDouble() * math.pi * 2,
        distance: 0.18 + random.nextDouble() * 0.78,
      );
    });
  }

  Duration _durationForRadius(double radius) {
    final t = ((radius - _minRadius) / (_maxRadius - _minRadius)).clamp(0.0, 1.0);
    final ms = (4200 - t * 2400).round();
    return Duration(milliseconds: ms);
  }

  int _visibleBlipCount(double radius) {
    final t = ((radius - _minRadius) / (_maxRadius - _minRadius)).clamp(0.0, 1.0);
    return (4 + t * 16).round().clamp(4, _allBlips.length);
  }

  void _updateBlipGlow() {
    final beam = _sweepController.value * math.pi * 2;
    const hitWindow = 0.22;
    var changed = false;

    for (var i = 0; i < _visibleBlipCount(_radius); i++) {
      final blip = _allBlips[i];
      var delta = (beam - blip.angle).abs();
      if (delta > math.pi) delta = math.pi * 2 - delta;
      if (delta < hitWindow) {
        if (blip.glow < 1) {
          blip.glow = 1;
          changed = true;
        }
      } else if (blip.glow > 0.01) {
        blip.glow *= 0.94;
        changed = true;
      } else if (blip.glow != 0) {
        blip.glow = 0;
        changed = true;
      }
    }

    if (changed && mounted) setState(() {});
  }

  void _onRadiusChanged(double value) {
    setState(() => _radius = value);
    _sweepController.duration = _durationForRadius(value);
    if (!_sweepController.isAnimating) {
      _sweepController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _allBlips.take(_visibleBlipCount(_radius)).toList();

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
            'РАДАР ДАЛЬНОСТЬ: ${_radius.round()} КМ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _matrixGreen,
              fontFamily: 'monospace',
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  color: _matrixGreen.withValues(alpha: 0.75),
                  blurRadius: 12,
                ),
                Shadow(
                  color: _neonCyan.withValues(alpha: 0.35),
                  blurRadius: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _sweepController,
                builder: (context, _) {
                  return SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: _CyberRadarPainter(
                        sweepAngle: _sweepController.value * math.pi * 2,
                        blips: visible,
                        accent: _neonCyan,
                        hitColor: _matrixGreen,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'КОНТАКТЫ: ${visible.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _neonCyan,
              inactiveTrackColor: AppColors.border,
              thumbColor: _matrixGreen,
              overlayColor: _neonCyan.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
            ),
            child: Slider(
              min: _minRadius,
              max: _maxRadius,
              divisions: 49,
              value: _radius,
              onChanged: _onRadiusChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '1 КМ',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontFamily: 'monospace',
                  fontSize: 9,
                ),
              ),
              Text(
                '50 КМ',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontFamily: 'monospace',
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CyberRadarPainter extends CustomPainter {
  final double sweepAngle;
  final List<_RadarBlip> blips;
  final Color accent;
  final Color hitColor;

  _CyberRadarPainter({
    required this.sweepAngle,
    required this.blips,
    required this.accent,
    required this.hitColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;

    final bgPaint = Paint()
      ..color = const Color(0xFF050808)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final ringPaint = Paint()
      ..color = accent.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, ringPaint);
    }

    final crossPaint = Paint()
      ..color = accent.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crossPaint,
    );

    final diag = radius * 0.707;
    canvas.drawLine(
      Offset(center.dx - diag, center.dy - diag),
      Offset(center.dx + diag, center.dy + diag),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx - diag, center.dy + diag),
      Offset(center.dx + diag, center.dy - diag),
      crossPaint,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweepAngle);
    final sweepPaint = Paint()
      ..shader = ui.Gradient.sweep(
        Offset.zero,
        [
          accent.withValues(alpha: 0.55),
          accent.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        [0.0, 0.12, 0.35],
      )
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: radius),
      -0.35,
      0.7,
      true,
      sweepPaint,
    );
    canvas.restore();

    final beamPaint = Paint()
      ..color = accent.withValues(alpha: 0.85)
      ..strokeWidth = 2;
    final beamEnd = Offset(
      center.dx + math.cos(sweepAngle) * radius,
      center.dy + math.sin(sweepAngle) * radius,
    );
    canvas.drawLine(center, beamEnd, beamPaint);

    for (final blip in blips) {
      final px = center.dx + math.cos(blip.angle) * radius * blip.distance;
      final py = center.dy + math.sin(blip.angle) * radius * blip.distance;
      final glow = blip.glow.clamp(0.0, 1.0);
      final baseColor = Color.lerp(
        AppColors.textDisabled.withValues(alpha: 0.35),
        hitColor,
        glow,
      )!;

      if (glow > 0.05) {
        canvas.drawCircle(
          Offset(px, py),
          6 + glow * 4,
          Paint()
            ..color = hitColor.withValues(alpha: 0.25 * glow)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }

      canvas.drawCircle(
        Offset(px, py),
        2.5 + glow * 1.5,
        Paint()
          ..color = baseColor
          ..style = PaintingStyle.fill,
      );
    }

    final borderPaint = Paint()
      ..color = accent.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CyberRadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        !_sameBlips(oldDelegate.blips, blips);
  }

  bool _sameBlips(List<_RadarBlip> a, List<_RadarBlip> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].glow != b[i].glow) return false;
    }
    return true;
  }
}
