import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

const _defaultMessage = 'ПРОИЗОШЛА ОШИБКА. ПОПРОБУЙТЕ ПОЗЖЕ';
const _noConnectionMessage = 'НЕТ СВЯЗИ С СЕРВЕРОМ';

/// Единый маппер Firebase Auth / Firestore / сетевых ошибок для UI (RU, CAPS).
String mapFirebaseError(Object error) {
  if (error is FirebaseAuthException) {
    return _messageForCode(error.code, plugin: 'firebase_auth');
  }
  if (error is FirebaseException) {
    return _messageForCode(error.code, plugin: error.plugin);
  }

  final extracted = _extractCodeFromMessage(error.toString());
  if (extracted != null) {
    return _messageForCode(extracted.code, plugin: extracted.plugin);
  }

  return _defaultMessage;
}

/// @deprecated Используйте [mapFirebaseError].
String mapFirebaseAuthError(FirebaseAuthException e) => mapFirebaseError(e);

({String? plugin, String code})? _extractCodeFromMessage(String message) {
  final match = RegExp(r'\[([^/\]]+)/([^\]]+)\]').firstMatch(message);
  if (match == null) return null;
  return (plugin: match.group(1), code: match.group(2)!);
}

String _messageForCode(String code, {String? plugin}) {
  final full = plugin != null ? '$plugin/$code' : code;
  final normalized = code.contains('/') ? code.split('/').last : code;

  switch (full) {
    case 'firebase_auth/user-not-found':
      return 'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН';
    case 'firebase_auth/wrong-password':
      return 'НЕВЕРНЫЙ ПАРОЛЬ';
    case 'firebase_auth/email-already-in-use':
      return 'АККАУНТ УЖЕ СУЩЕСТВУЕТ';
    case 'firebase_auth/invalid-email':
      return 'НЕКОРРЕКТНЫЙ EMAIL';
    case 'cloud_firestore/unavailable':
      return _noConnectionMessage;
  }

  switch (normalized) {
    case 'user-not-found':
      return 'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН';
    case 'wrong-password':
    case 'invalid-credential':
      return 'НЕВЕРНЫЙ ПАРОЛЬ';
    case 'email-already-in-use':
      return 'АККАУНТ УЖЕ СУЩЕСТВУЕТ';
    case 'invalid-email':
      return 'НЕКОРРЕКТНЫЙ EMAIL';
    case 'unavailable':
    case 'network-request-failed':
    case 'deadline-exceeded':
      return _noConnectionMessage;
    case 'too-many-requests':
      return 'СЛИШКОМ МНОГО ПОПЫТОК. ПОПРОБУЙТЕ ПОЗЖЕ';
    case 'weak-password':
      return 'СЛИШКОМ СЛАБЫЙ ПАРОЛЬ';
    case 'user-disabled':
      return 'АККАУНТ ЗАБЛОКИРОВАН';
    case 'operation-not-allowed':
      return 'ВХОД ЧЕРЕЗ EMAIL ОТКЛЮЧЁН';
    default:
      return _defaultMessage;
  }
}
