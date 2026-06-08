import 'dart:async';

import 'package:flutter/material.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/translation/translation_service.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class CyberDecryptionText extends StatefulWidget {
  final String text;
  final String targetLanguageCode;
  final TextStyle? style;

  const CyberDecryptionText({
    super.key,
    required this.text,
    required this.targetLanguageCode,
    this.style,
  });

  @override
  State<CyberDecryptionText> createState() => _CyberDecryptionTextState();
}

class _CyberDecryptionTextState extends State<CyberDecryptionText>
    with SingleTickerProviderStateMixin {
  static const _errorPrefix = '[SYS.ERR: DECRYPTION FAILED] ';

  late final AnimationController _pulseController;

  bool _isLoading = true;
  bool _hasError = false;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _decrypt();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _decrypt() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _pulseController.repeat(reverse: true);

    try {
      final translated = await TranslationService.instance
          .translateText(
            text: widget.text,
            targetLanguageCode: widget.targetLanguageCode,
          )
          .timeout(const Duration(seconds: 3));

      if (!mounted) return;

      _pulseController.stop();
      setState(() {
        _isLoading = false;
        _hasError = false;
        _displayText = translated;
      });
    } on TimeoutException {
      _applyFailure();
    } catch (_) {
      _applyFailure();
    }
  }

  void _applyFailure() {
    if (!mounted) return;
    _pulseController.stop();
    setState(() {
      _isLoading = false;
      _hasError = true;
      _displayText = '$_errorPrefix${widget.text}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final baseStyle = widget.style ??
        const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.4,
          fontFamily: 'monospace',
        );

    if (_isLoading) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final opacity = 0.45 + _pulseController.value * 0.55;
          return Text(
            l10n.decryptionInProgress,
            style: baseStyle.copyWith(
              color: AppColors.neonRed.withValues(alpha: opacity),
              letterSpacing: 1.2,
            ),
          );
        },
      );
    }

    if (_hasError) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: _errorPrefix,
              style: baseStyle.copyWith(
                color: AppColors.neonRed,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: widget.text,
              style: baseStyle,
            ),
          ],
        ),
      );
    }

    return Text(
      _displayText,
      style: baseStyle,
    );
  }

  @override
  void didUpdateWidget(covariant CyberDecryptionText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.targetLanguageCode != widget.targetLanguageCode) {
      _decrypt();
    }
  }
}
