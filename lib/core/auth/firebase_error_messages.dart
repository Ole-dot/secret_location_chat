import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

const _defaultMessage = 'errorGeneric';
const _noConnectionMessage = 'errorNoConnection';

/// Единый маппер Firebase Auth / Firestore / сетевых ошибок.
/// Возвращает СТАБИЛЬНЫЙ КЛЮЧ ошибки (см. ARB / [l10nByKey]), а не текст —
/// локализация выполняется в UI через `l10nByKey(l10n, key)`.
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
      return 'errorUserNotFound';
    case 'firebase_auth/wrong-password':
      return 'errorWrongPassword';
    case 'firebase_auth/email-already-in-use':
      return 'errorEmailInUse';
    case 'firebase_auth/invalid-email':
      return 'errorInvalidEmail';
    case 'cloud_firestore/unavailable':
      return _noConnectionMessage;
  }

  switch (normalized) {
    case 'user-not-found':
      return 'errorUserNotFound';
    case 'wrong-password':
    case 'invalid-credential':
      return 'errorWrongPassword';
    case 'email-already-in-use':
      return 'errorEmailInUse';
    case 'invalid-email':
      return 'errorInvalidEmail';
    case 'unavailable':
    case 'network-request-failed':
    case 'deadline-exceeded':
      return _noConnectionMessage;
    case 'too-many-requests':
      return 'errorTooManyRequests';
    case 'weak-password':
      return 'errorWeakPassword';
    case 'user-disabled':
      return 'errorUserDisabled';
    case 'operation-not-allowed':
      return 'errorEmailSignInDisabled';
    default:
      return _defaultMessage;
  }
}
