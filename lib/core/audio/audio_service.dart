import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Centralized UI sound effects (local assets, preloaded for low latency).
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static final _clickAsset = AssetSource('sounds/click.mp3');
  static final _sendAsset = AssetSource('sounds/send.mp3');
  static final _errorAsset = AssetSource('sounds/error.mp3');
  static final _successAsset = AssetSource('sounds/success.mp3');

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _sendPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Future.wait([
      _clickPlayer.setReleaseMode(ReleaseMode.stop),
      _sendPlayer.setReleaseMode(ReleaseMode.stop),
      _errorPlayer.setReleaseMode(ReleaseMode.stop),
      _successPlayer.setReleaseMode(ReleaseMode.stop),
      _clickPlayer.setSource(_clickAsset),
      _sendPlayer.setSource(_sendAsset),
      _errorPlayer.setSource(_errorAsset),
      _successPlayer.setSource(_successAsset),
    ]);
    _initialized = true;
  }

  void playClick() => _replay(_clickPlayer);

  void playSend() => _replay(_sendPlayer);

  void playError() => _replay(_errorPlayer);

  void playSuccess() => _replay(_successPlayer);

  Future<void> _replay(AudioPlayer player) async {
    if (!_initialized) {
      try {
        await init();
      } catch (e, st) {
        debugPrint('[AudioService] init failed: $e\n$st');
        return;
      }
    }
    try {
      await player.stop();
      await player.seek(Duration.zero);
      await player.resume();
    } catch (e) {
      debugPrint('[AudioService] playback failed: $e');
    }
  }

  Future<void> dispose() async {
    await Future.wait([
      _clickPlayer.dispose(),
      _sendPlayer.dispose(),
      _errorPlayer.dispose(),
      _successPlayer.dispose(),
    ]);
    _initialized = false;
  }
}
