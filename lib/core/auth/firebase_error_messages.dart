import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

const _defaultMessage = 'errorGeneric';

/// Human-readable error for SnackBars and debug output (not an l10n key).
String formatErrorForDisplay(Object error) {
  if (error is FirebaseAuthException) {
    final message = error.message?.trim();
    if (message != null && message.isNotEmpty) {
      return '[firebase_auth/${error.code}] $message';
    }
    return '[firebase_auth/${error.code}]';
  }
  if (error is FirebaseException) {
    final plugin = error.plugin.isNotEmpty ? error.plugin : 'firebase';
    final message = error.message?.trim();
    if (message != null && message.isNotEmpty) {
      return '[$plugin/${error.code}] $message';
    }
    return '[$plugin/${error.code}]';
  }
  if (error is StateError) {
    return switch (error.message) {
      'INSUFFICIENT_STONES' => 'НЕДОСТАТОЧНО СТОУНОВ',
      'CANNOT_GIFT_SELF' => 'НЕЛЬЗЯ ОТПРАВИТЬ СЕБЕ',
      'USER_NOT_FOUND' => 'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН',
      'INVALID_STONES_AMOUNT' => 'Некорректная сумма стоунов',
      'INVALID_GIFT_PRICE' => 'Некорректная цена гифта',
      _ => error.message,
    };
  }
  return error.toString();
}

void logPurchaseError(String scope, Object error, [StackTrace? stackTrace]) {
  debugPrint('[$scope] ${formatErrorForDisplay(error)}');
  if (stackTrace != null) {
    debugPrint(stackTrace.toString());
  }
}
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
