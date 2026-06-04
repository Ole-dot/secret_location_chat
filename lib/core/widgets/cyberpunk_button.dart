import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';

class CyberpunkButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;

  const CyberpunkButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 52,
  });

  @override
  State<CyberpunkButton> createState() => _CyberpunkButtonState();
}

class _CyberpunkButtonState extends State<CyberpunkButton>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _glitchController;
  late final Animation<double> _breathScale;
  late final Animation<double> _breathGlow;
  late final Animation<double> _glitchShift;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    _breathScale = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _breathGlow = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _glitchShift = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -3.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 2.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _glitchController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isLoading || widget.onPressed == null) return;
    _glitchController.forward(from: 0);
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: Listenable.merge([_breathController, _glitchController]),
      builder: (context, child) {
        final glitchActive = _glitchController.isAnimating;
        final jitterY = glitchActive
            ? math.sin(_glitchController.value * math.pi * 6) * 1.5
            : 0.0;
        final skew = glitchActive
            ? math.sin(_glitchController.value * math.pi * 4) * 0.02
            : 0.0;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(_glitchShift.value, jitterY)
            ..rotateZ(skew),
          child: Transform.scale(
            scale: enabled ? _breathScale.value : 1.0,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: enabled ? _handleTap : null,
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            color: widget.isOutlined
                ? AppColors.transparent
                : AppColors.neonRed,
            border: Border.all(
              color: AppColors.neonRed,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: enabled && !widget.isOutlined
                ? [
                    BoxShadow(
                      color: AppColors.neonRed
                          .withValues(alpha: _breathGlow.value),
                      blurRadius: 14 + _breathGlow.value * 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  widget.text.toUpperCase(),
                  style: TextStyle(
                    color: widget.isOutlined
                        ? AppColors.neonRed
                        : AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
        ),
      ),
    );
  }
}
