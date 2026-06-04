import 'package:flutter/material.dart';

class GiftAssetVisual {
  final IconData icon;
  final List<Color> gradient;

  const GiftAssetVisual({
    required this.icon,
    required this.gradient,
  });
}

const giftAssetVisuals = <String, GiftAssetVisual>{
  'neon_rose': GiftAssetVisual(
    icon: Icons.local_florist,
    gradient: [Color(0xFFFF006A), Color(0xFFFF4D4D)],
  ),
  'cyber_punk_2077': GiftAssetVisual(
    icon: Icons.memory,
    gradient: [Color(0xFFFFD500), Color(0xFF00E5FF)],
  ),
  'cyber_coffee': GiftAssetVisual(
    icon: Icons.coffee,
    gradient: [Color(0xFFFF8A00), Color(0xFFFF3D00)],
  ),
  'data_crystal': GiftAssetVisual(
    icon: Icons.diamond,
    gradient: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
  ),
  'ghost_drone': GiftAssetVisual(
    icon: Icons.toys,
    gradient: [Color(0xFF64FFDA), Color(0xFF00B0FF)],
  ),
  'black_lotus': GiftAssetVisual(
    icon: Icons.auto_awesome,
    gradient: [Color(0xFFFFD54F), Color(0xFFFF6F00)],
  ),
  'gift_default': GiftAssetVisual(
    icon: Icons.card_giftcard,
    gradient: [Color(0xFFFF1744), Color(0xFF651FFF)],
  ),
};

GiftAssetVisual resolveGiftAsset(String assetKey) {
  return giftAssetVisuals[assetKey] ?? giftAssetVisuals['gift_default']!;
}
