import 'dart:ui';

/// Цветовая палитра SLC — Cyberpunk / Y2K
/// Красный неон + глубокий чёрный
class AppColors {
  // Основные
  static const Color background    = Color(0xFF0A0A0A);  // глубокий чёрный
  static const Color surface       = Color(0xFF111111);  // чуть светлее фона
  static const Color surfaceCard   = Color(0xFF1A1A1A);  // карточки

  // Акцент — неоновый красный
  static const Color neonRed       = Color(0xFFFF0033);
  static const Color neonRedDark   = Color(0xFFCC0028);
  static const Color neonRedGlow   = Color(0x66FF0033);  // для свечения

  // Текст
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textDisabled  = Color(0xFF444444);

  // Вспомогательные
  static const Color border        = Color(0xFF2A2A2A);
  static const Color borderRed     = Color(0x44FF0033);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color black         = Color(0xFF000000);
  static const Color transparent   = Color(0x00000000);

  // Тёмная карта overlay
  static const Color mapOverlay    = Color(0x88000000);
}
