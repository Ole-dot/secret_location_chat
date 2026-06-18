import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/data/models/ephemeral_message.dart';

/// Plays a burn / glitch exit when [message.expiresAt] is reached, then calls
/// [onBurnComplete] so the parent list can remove the row without jank.
class BurningMessageWrapper extends StatefulWidget {
  final EphemeralMessage message;
  final VoidCallback onBurnComplete;
  final Widget child;

  const BurningMessageWrapper({
    super.key,
    required this.message,
    required this.onBurnComplete,
    required this.child,
  });

  @override
  State<BurningMessageWrapper> createState() => _BurningMessageWrapperState();
}

class _BurningMessageWrapperState extends State<BurningMessageWrapper>
    with SingleTickerProviderStateMixin {
  static const _burnDuration = Duration(milliseconds: 700);

  Timer? _expiryTimer;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _size;
  late final Animation<double> _glitch;

  bool _burning = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _burnDuration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _size = CurvedAnimation(parent: _controller, curve: Curves.easeInBack);
    _glitch = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.65)),
    );
    _scheduleExpiry();
  }

  @override
  void didUpdateWidget(BurningMessageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.expiresAt != widget.message.expiresAt) {
      _expiryTimer?.cancel();
      _scheduleExpiry();
    }
  }

  void _scheduleExpiry() {
    if (_burning || _completed) return;

    final remaining = widget.message.timeRemaining;
    if (remaining <= Duration.zero) {
      _startBurn();
      return;
    }

    _expiryTimer = Timer(remaining, _startBurn);
  }

  Future<void> _startBurn() async {
    if (!mounted || _burning || _completed) return;
    setState(() => _burning = true);
    await _controller.forward();
    if (!mounted || _completed) return;
    _completed = true;
    widget.onBurnComplete();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return const SizedBox.shrink();
    }

    if (!_burning) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glitchOffset = math.sin(_glitch.value * math.pi * 10) * 3;
        return SizeTransition(
          sizeFactor: Tween<double>(begin: 1, end: 0).animate(_size),
          axisAlignment: -1,
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(_fade),
            child: Transform.translate(
              offset: Offset(glitchOffset, 0),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix([
                  1 + _glitch.value * 0.8,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1 - _glitch.value * 0.5,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1 - _glitch.value * 0.5,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonRed
                            .withValues(alpha: 0.35 * _glitch.value),
                        blurRadius: 12 * _glitch.value,
                        spreadRadius: 2 * _glitch.value,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
