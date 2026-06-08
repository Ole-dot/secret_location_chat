import 'package:secret_location_chat/l10n/app_localizations.dart';

/// Resolves a stable error/message KEY (as emitted by blocs and
/// [mapFirebaseError]) into a localized string for the current locale.
///
/// Blocs and mappers stay context-free: they emit a key (e.g. `errorUserNotFound`),
/// and the UI layer calls [l10nByKey] to render it. Unknown values are returned
/// unchanged, so any already-localized or raw string still displays sanely.
String l10nByKey(AppLocalizations l10n, String key) {
  switch (key) {
    // Validation
    case 'validationInvalidEmail':
      return l10n.validationInvalidEmail;
    case 'validationPasswordMin':
      return l10n.validationPasswordMin;
    // Generic / network
    case 'errorGeneric':
      return l10n.errorGeneric;
    case 'errorNoConnection':
      return l10n.errorNoConnection;
    // Auth
    case 'errorUserNotFound':
      return l10n.errorUserNotFound;
    case 'errorWrongPassword':
      return l10n.errorWrongPassword;
    case 'errorEmailInUse':
      return l10n.errorEmailInUse;
    case 'errorInvalidEmail':
      return l10n.errorInvalidEmail;
    case 'errorTooManyRequests':
      return l10n.errorTooManyRequests;
    case 'errorWeakPassword':
      return l10n.errorWeakPassword;
    case 'errorUserDisabled':
      return l10n.errorUserDisabled;
    case 'errorEmailSignInDisabled':
      return l10n.errorEmailSignInDisabled;
    case 'errorEnterEmail':
      return l10n.errorEnterEmail;
    case 'errorCreateAccountFailed':
      return l10n.errorCreateAccountFailed;
    // Map / geo
    case 'errorGeoUnavailable':
      return l10n.errorGeoUnavailable;
    // Stones
    case 'errorUserUnauthorized':
      return l10n.errorUserUnauthorized;
    case 'errorStoreUnavailable':
      return l10n.errorStoreUnavailable;
    case 'errorPurchaseFailed':
      return l10n.errorPurchaseFailed;
    case 'errorProfileNotFound':
      return l10n.errorProfileNotFound;
    case 'errorInvalidAmount':
      return l10n.errorInvalidAmount;
    // Gifts
    case 'giftInsufficientStones':
      return l10n.giftInsufficientStones;
    case 'giftSent':
      return l10n.giftSent;
    case 'giftCannotSendSelf':
      return l10n.giftCannotSendSelf;
    case 'giftUserNotFound':
      return l10n.giftUserNotFound;
    default:
      return key;
  }
}
