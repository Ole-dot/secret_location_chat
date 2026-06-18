// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Secret Location Chat';

  @override
  String get commonBack => '← Back';

  @override
  String get commonBackToLogin => '← Back to login';

  @override
  String get commonCancel => 'CANCEL';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSend => 'Send';

  @override
  String get commonDelete => 'DELETE';

  @override
  String get commonDownload => 'DOWNLOAD';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get authRequiredChat => 'Chat unavailable';

  @override
  String get authRequiredStones => 'Sign in to buy Stones';

  @override
  String get authRequiredGifts => 'Sign in to send gifts';

  @override
  String get authRequiredTerminalHack => 'Sign in for TERMINAL HACK';

  @override
  String get errorGeneric => 'AN ERROR OCCURRED. TRY AGAIN LATER';

  @override
  String get errorNoConnection => 'NO SERVER CONNECTION';

  @override
  String get errorUserNotFound => 'USER NOT FOUND';

  @override
  String get errorWrongPassword => 'WRONG PASSWORD';

  @override
  String get errorEmailInUse => 'ACCOUNT ALREADY EXISTS';

  @override
  String get errorInvalidEmail => 'INVALID EMAIL';

  @override
  String get errorTooManyRequests => 'TOO MANY ATTEMPTS. TRY AGAIN LATER';

  @override
  String get errorWeakPassword => 'PASSWORD TOO WEAK';

  @override
  String get errorUserDisabled => 'ACCOUNT BLOCKED';

  @override
  String get errorEmailSignInDisabled => 'EMAIL SIGN-IN DISABLED';

  @override
  String get errorEnterEmail => 'ENTER EMAIL';

  @override
  String get errorCreateAccountFailed => 'FAILED TO CREATE ACCOUNT';

  @override
  String get errorGeoUnavailable => 'Geolocation unavailable';

  @override
  String get errorUserUnauthorized => 'USER NOT AUTHORIZED';

  @override
  String get errorStoreUnavailable => 'STORE UNAVAILABLE';

  @override
  String get errorPurchaseFailed => 'PURCHASE ERROR';

  @override
  String get errorProfileNotFound => 'PROFILE NOT FOUND';

  @override
  String get errorInvalidAmount => 'INVALID AMOUNT';

  @override
  String get validationInvalidEmail => 'Invalid email format';

  @override
  String get validationPasswordMin => 'Minimum 6 characters';

  @override
  String get giftDescNeonRose => 'A digital rose with a neon glow';

  @override
  String get giftDescCyberCoffee => 'A hot drink from an underground bar';

  @override
  String get giftDescDataCrystal => 'A rare crystal of encrypted data';

  @override
  String get giftDescGhostDrone => 'A mini-drone for covert delivery';

  @override
  String get authTitle => 'LOGIN';

  @override
  String get authSubtitle => '// IDENTIFICATION //';

  @override
  String get fieldPassword => 'PASSWORD';

  @override
  String get authLoginButton => 'Login';

  @override
  String get authForgotPassword => 'Forgot password? → RESET';

  @override
  String get authToRegister => 'New here? → SIGN UP';

  @override
  String get resetTitle => 'RESET';

  @override
  String get resetSubtitle => '// ACCESS RECOVERY //';

  @override
  String get resetEmailLanguage => 'EMAIL LANGUAGE';

  @override
  String get resetSendLink => 'Send link';

  @override
  String get resetLinkSent => 'Password reset link sent to your email';

  @override
  String get resetDeviceLangKaz => '(device language: KAZ)';

  @override
  String get resetDeviceLangRus => '(device language: RUS)';

  @override
  String get resetLangRus => 'RUS';

  @override
  String get resetLangKaz => 'KAZ';

  @override
  String get registerTitle => 'SIGN UP';

  @override
  String get registerSubtitle => '// CREATE IDENTITY //';

  @override
  String get registerNickLabel => 'NICKNAME (optional)';

  @override
  String get registerNickHint => 'empty → Acid Raccoon';

  @override
  String get registerNickNote =>
      '// otherwise a random cyber-nick on sign-up //';

  @override
  String get registerButton => 'Sign up';

  @override
  String get registerHaveAccount => 'Already have an account? → LOGIN';

  @override
  String get splashSubtitle => '// ANONYMOUS GEO-MESSENGER //';

  @override
  String get splashEnableLocation => '⦿  Enable location';

  @override
  String get splashLogin => 'Login';

  @override
  String get splashNoAccount => 'No account? Sign up →';

  @override
  String get chatTitle => 'GLOBAL CHAT';

  @override
  String get chatYouTyped => 'YOU TYPED';

  @override
  String get chatInputHint => 'Message to global chat...';

  @override
  String get editIdentityEnterNick => 'ENTER NICKNAME';

  @override
  String get editIdentityUpdated => 'IDENTITY UPDATED';

  @override
  String get editIdentityTitle => 'CHANGE IDENTITY';

  @override
  String get editIdentityNickLabel => 'NICKNAME';

  @override
  String get editIdentityNickHint => 'Acid Raccoon';

  @override
  String get editIdentityRegisteredEmailLabel => 'REGISTERED EMAIL';

  @override
  String get editIdentityAvatarLabel => 'AVATAR';

  @override
  String get geolocationTitle => 'GEOLOCATION';

  @override
  String get securityTitle => 'SECURITY';

  @override
  String get notificationsTitle => 'NOTIFICATIONS';

  @override
  String get languageTitle => 'LANGUAGE';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsConfigure => 'Configure';

  @override
  String get settingsNotifications => 'NOTIFICATIONS';

  @override
  String get settingsSecurity => 'SECURITY';

  @override
  String get settingsLanguage => 'LANGUAGE';

  @override
  String get volumeLabel => 'NOTIFICATION VOLUME';

  @override
  String get offlineMapsTitle => 'OFFLINE MAPS';

  @override
  String get offlineMapsHint =>
      'DOWNLOAD MAP AREAS IN ADVANCE — IN THE FIELD WITHOUT CONNECTION TILES WILL BE TAKEN FROM CACHE.';

  @override
  String get offlineMapsSoon => '// SOON: SELECT A RECTANGLE ON THE MAP //';

  @override
  String get offlineRegionNorth => 'NORTH SECTOR';

  @override
  String get offlineRegionBaseCamp => 'BASE CAMP';

  @override
  String get offlineRegionSouthValley => 'SOUTH VALLEY';

  @override
  String get offlineRegionPolygonA7 => 'POLYGON A-7';

  @override
  String offlineRegionCached(String name) {
    return '$name — CACHED';
  }

  @override
  String offlineRegionDeleted(String name) {
    return '$name — DELETED';
  }

  @override
  String get logoutTitle => 'LOG OUT';

  @override
  String get logoutConfirm => 'END SESSION AND LOG OUT OF YOUR ACCOUNT?';

  @override
  String get logoutButton => 'LOG OUT';

  @override
  String get menuHeader => '// PROFILE · SYSTEM //';

  @override
  String get menuFindUser => 'FIND USER';

  @override
  String get menuChangeIdentity => 'CHANGE IDENTITY';

  @override
  String get menuChangePlan => 'CHANGE PLAN';

  @override
  String get menuOfflineMaps => 'OFFLINE MAPS';

  @override
  String get menuSettings => 'SETTINGS';

  @override
  String get menuLogout => 'LOG OUT';

  @override
  String get searchEnterEmail => 'ENTER EMAIL';

  @override
  String get searchEnterNickname => 'ENTER NICKNAME';

  @override
  String get searchEnterQuery => 'ENTER USERNAME OR EMAIL';

  @override
  String get searchNicknameLabel => 'NICKNAME';

  @override
  String get searchNicknameHint => 'Nickname (first letters)...';

  @override
  String get searchQueryLabel => 'USERNAME OR EMAIL';

  @override
  String get searchQueryHint => 'Search by username or email...';

  @override
  String get searchTitle => 'FIND USER';

  @override
  String get searchSubtitle => '// SMART SEARCH · USERNAME OR EMAIL //';

  @override
  String get searchButton => 'Search';

  @override
  String get searchNotFound => 'USER NOT FOUND';

  @override
  String get searchTapToSelect => 'TAP TO SELECT';

  @override
  String get searchSendGift => 'SEND GIFT';

  @override
  String get searchAddFriend => 'ADD FRIEND';

  @override
  String get searchRequestSent => 'REQUEST SENT';

  @override
  String get searchAlreadyFriends => 'CONNECTED';

  @override
  String get searchIncomingRequest => 'INCOMING REQUEST';

  @override
  String get mapStyleDark => 'Dark';

  @override
  String get mapStyleSatellite => '3D / Satellite';

  @override
  String get mapStyleMinimal => 'Minimal';

  @override
  String get mapCloseAppTitle => 'Close app?';

  @override
  String mapSignalsCount(int count) {
    return '$count signals';
  }

  @override
  String get mapPremiumHint =>
      '🔒 Available in Premium — tap the plan to switch';

  @override
  String get messagePendingSync => 'Awaiting upload to server';

  @override
  String messagePendingSyncAt(String time) {
    return '⏳ awaiting sync · $time';
  }

  @override
  String messageRepliesCount(int count) {
    return '$count replies';
  }

  @override
  String get messageToChat => 'TO CHAT →';

  @override
  String get sendMessageTitle => 'NEW MESSAGE';

  @override
  String get sendMessageHint => 'What\'s happening here?';

  @override
  String get sendMessageTtl => 'TIME TO LIVE';

  @override
  String get sendAnonymously => '◉  Send anonymously';

  @override
  String get sendPremiumHint => '🔒 Available in Premium (₸5000/mo)';

  @override
  String get decryptionInProgress => '[ DECRYPTING TRANSMISSION... ]';

  @override
  String get giftInsufficientStones => 'NOT ENOUGH STONES';

  @override
  String get giftSent => 'GIFT SENT';

  @override
  String get giftCannotSendSelf => 'CANNOT SEND TO YOURSELF';

  @override
  String get giftUserNotFound => 'USER NOT FOUND';

  @override
  String get stonesSubtitle => '// IN-GAME CURRENCY //';

  @override
  String get stonesDescription =>
      'Top up your Stones balance to send gifts in chat.';

  @override
  String get stonesRefreshStore => 'REFRESH STORE';

  @override
  String get planTitle => 'PRICING PLAN';

  @override
  String get planMissingHint => 'Open plans from the map';

  @override
  String get planToMap => 'To map';

  @override
  String get planTestModeBanner =>
      'Test mode — switch the plan and instantly check all features';

  @override
  String get planBadgeHit => 'HOT';

  @override
  String get planBadgeActive => 'ACTIVE';

  @override
  String get planSelect => 'SELECT';

  @override
  String planActivate(String plan) {
    return 'Activate $plan';
  }

  @override
  String planActivatedSnack(String plan) {
    return 'Plan $plan activated';
  }

  @override
  String get planFreeSubtitle => 'Basic';

  @override
  String get planPremiumSubtitle => 'Popular';

  @override
  String get planEnterpriseSubtitle => 'For teams and business';

  @override
  String get planFeatMsg5PerDay => 'Up to 5 messages per day';

  @override
  String get planFeatTtl1h => 'TTL up to 1 hour';

  @override
  String get planFeatStandardNick => 'Standard nick on the map';

  @override
  String get planFeatAnonMode => 'Anonymous mode';

  @override
  String get planFeatTtl24h => 'TTL up to 24 hours';

  @override
  String get planFeatAvatarsGifts => 'Avatars and gifts';

  @override
  String get planFeatTotemCompass => 'Totem Compass';

  @override
  String get planFeatUnityGame => 'Unity game';

  @override
  String get planFeatPrivateZones => 'Private zones';

  @override
  String get planFeatUnlimitedMsg => 'Unlimited messages';

  @override
  String get planFeatAnonShadow => 'Anonymous mode (Shadow_XXXX)';

  @override
  String get planFeatCustomAvatars => 'Custom avatars';

  @override
  String get planFeatGiftsToUsers => 'Gifts to other users';

  @override
  String get planFeatApiIntegrations => 'API integrations';

  @override
  String get planFeatAllPremium => 'Everything from Premium';

  @override
  String get planFeatPrivateGeozones => 'Private geozones';

  @override
  String get planFeatTeamChats => 'Team chats';

  @override
  String get planFeatActivityAnalytics => 'Activity analytics';

  @override
  String get planFeatWhiteLabel => 'White-label branding';

  @override
  String get planFeatPrioritySupport => 'Priority support';

  @override
  String get planFeatE2eEncryption => 'E2E encryption';

  @override
  String get planFeatSlaGuarantees => 'SLA guarantees';

  @override
  String get modeAnon => 'ANON';

  @override
  String get modeOpen => 'OPEN';

  @override
  String get unitMin => 'min';

  @override
  String get unitHour => 'h';

  @override
  String get unitMb => 'MB';

  @override
  String get perMonth => ' / mo';

  @override
  String durationHoursMinutes(int h, int m) {
    return '${h}h ${m}min';
  }

  @override
  String durationMinutes(int m) {
    return '${m}min';
  }

  @override
  String durationSeconds(int s) {
    return '${s}s';
  }

  @override
  String get eventsPullUp => 'PULL UP · EVENTS';

  @override
  String get eventsTerminalTitle => 'EVENTS TERMINAL';

  @override
  String get eventsTabGlobal => 'Global';

  @override
  String get eventsTabMyLogs => 'My Logs';

  @override
  String get eventsTabNetwork => 'NETWORK';

  @override
  String get eventsNetworkEmpty => 'NO ACTIVE INCOMING CONNECTIONS';

  @override
  String get eventsGlobalEmpty => 'NETWORK EMPTY';

  @override
  String get eventsMyLogsEmpty => 'NO DATA FOUND';

  @override
  String get eventsSignalLost => '// SIGNAL LOST //';

  @override
  String get eventsQueryOkZeroHits => '[ QUERY OK · ZERO HITS ]';

  @override
  String get eventsReplyPrefix => '[REPLY TO SYS.MSG] ';

  @override
  String get eventsTimestampUnavailable => '--:--';

  @override
  String get eventsNetworkTimeout =>
      'Network error: [timeout] No response from Firestore';

  @override
  String eventsNetworkError(String code, String message) {
    return 'Network error: [$code] $message';
  }

  @override
  String get menuTerminalHack => 'TERMINAL HACK';

  @override
  String get menuStones => 'STONES';

  @override
  String get menuGiftStore => 'GIFT STORE';

  @override
  String get settingsClan => 'MY CLAN';

  @override
  String get settingsClanSubtitle => 'Manage your clan';
}
