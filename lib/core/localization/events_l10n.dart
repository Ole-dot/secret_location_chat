import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

const eventsNetworkTimeoutKey = 'eventsNetworkTimeout';

String formatEventsNetworkError(String code, String message) {
  return 'eventsNetworkError|$code|$message';
}

bool isEventsNetworkError(String value) {
  return value == eventsNetworkTimeoutKey ||
      value.startsWith('eventsNetworkError|') ||
      value.startsWith('Ошибка сети:');
}

/// Full Firebase / network detail for copy-paste (index URLs, etc.).
String eventsRawFirebaseMessage(String message) {
  if (message.startsWith('eventsNetworkError|')) {
    final secondPipe = message.indexOf('|', 'eventsNetworkError|'.length);
    if (secondPipe != -1 && secondPipe + 1 < message.length) {
      return message.substring(secondPipe + 1);
    }
  }
  return message;
}

String resolveEventsErrorMessage(AppLocalizations l10n, String message) {
  if (message == eventsNetworkTimeoutKey) {
    return l10n.eventsNetworkTimeout;
  }
  if (message.startsWith('eventsNetworkError|')) {
    final parts = message.split('|');
    if (parts.length >= 3) {
      return l10n.eventsNetworkError(
        parts[1],
        parts.sublist(2).join('|'),
      );
    }
    return message;
  }
  if (message.contains('\n')) {
    return message
        .split('\n')
        .map((line) => resolveEventsErrorMessage(l10n, line))
        .join('\n');
  }
  final resolved = l10nByKey(l10n, message);
  if (resolved != message) {
    return resolved;
  }
  return message;
}
