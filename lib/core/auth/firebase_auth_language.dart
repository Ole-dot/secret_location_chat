import 'dart:ui' show PlatformDispatcher;

/// Коды языка, которые поддерживает Firebase Auth для писем (ru / kk).
const firebaseAuthLanguageRu = 'ru';
const firebaseAuthLanguageKk = 'kk';

/// Возвращает `ru` или `kk` для [FirebaseAuth.setLanguageCode].
///
/// [override] — явный выбор (`ru` / `kk` / `kz`), иначе берётся локаль устройства.
String resolveFirebaseAuthLanguageCode([String? override]) {
  if (override != null) {
    final code = override.toLowerCase();
    if (code == firebaseAuthLanguageKk || code == 'kz') {
      return firebaseAuthLanguageKk;
    }
    return firebaseAuthLanguageRu;
  }

  final deviceCode =
      PlatformDispatcher.instance.locale.languageCode.toLowerCase();
  if (deviceCode == firebaseAuthLanguageKk || deviceCode == 'kz') {
    return firebaseAuthLanguageKk;
  }
  return firebaseAuthLanguageRu;
}
