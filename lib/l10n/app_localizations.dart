import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Secret Location Chat'**
  String get appTitle;

  /// Generic back link
  ///
  /// In en, this message translates to:
  /// **'← Back'**
  String get commonBack;

  /// No description provided for @commonBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'← Back to login'**
  String get commonBackToLogin;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get commonDelete;

  /// No description provided for @commonDownload.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get commonDownload;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// Shown when chat cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Chat unavailable'**
  String get authRequiredChat;

  /// No description provided for @authRequiredStones.
  ///
  /// In en, this message translates to:
  /// **'Sign in to buy Stones'**
  String get authRequiredStones;

  /// No description provided for @authRequiredGifts.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send gifts'**
  String get authRequiredGifts;

  /// No description provided for @authRequiredTerminalHack.
  ///
  /// In en, this message translates to:
  /// **'Sign in for TERMINAL HACK'**
  String get authRequiredTerminalHack;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'AN ERROR OCCURRED. TRY AGAIN LATER'**
  String get errorGeneric;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'NO SERVER CONNECTION'**
  String get errorNoConnection;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'USER NOT FOUND'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'WRONG PASSWORD'**
  String get errorWrongPassword;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT ALREADY EXISTS'**
  String get errorEmailInUse;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'INVALID EMAIL'**
  String get errorInvalidEmail;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'TOO MANY ATTEMPTS. TRY AGAIN LATER'**
  String get errorTooManyRequests;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD TOO WEAK'**
  String get errorWeakPassword;

  /// No description provided for @errorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT BLOCKED'**
  String get errorUserDisabled;

  /// No description provided for @errorEmailSignInDisabled.
  ///
  /// In en, this message translates to:
  /// **'EMAIL SIGN-IN DISABLED'**
  String get errorEmailSignInDisabled;

  /// No description provided for @errorEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'ENTER EMAIL'**
  String get errorEnterEmail;

  /// No description provided for @errorCreateAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'FAILED TO CREATE ACCOUNT'**
  String get errorCreateAccountFailed;

  /// No description provided for @errorGeoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Geolocation unavailable'**
  String get errorGeoUnavailable;

  /// No description provided for @errorUserUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'USER NOT AUTHORIZED'**
  String get errorUserUnauthorized;

  /// No description provided for @errorStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'STORE UNAVAILABLE'**
  String get errorStoreUnavailable;

  /// No description provided for @errorPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'PURCHASE ERROR'**
  String get errorPurchaseFailed;

  /// No description provided for @errorProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'PROFILE NOT FOUND'**
  String get errorProfileNotFound;

  /// No description provided for @errorInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'INVALID AMOUNT'**
  String get errorInvalidAmount;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get validationPasswordMin;

  /// No description provided for @giftDescNeonRose.
  ///
  /// In en, this message translates to:
  /// **'A digital rose with a neon glow'**
  String get giftDescNeonRose;

  /// No description provided for @giftDescCyberCoffee.
  ///
  /// In en, this message translates to:
  /// **'A hot drink from an underground bar'**
  String get giftDescCyberCoffee;

  /// No description provided for @giftDescDataCrystal.
  ///
  /// In en, this message translates to:
  /// **'A rare crystal of encrypted data'**
  String get giftDescDataCrystal;

  /// No description provided for @giftDescGhostDrone.
  ///
  /// In en, this message translates to:
  /// **'A mini-drone for covert delivery'**
  String get giftDescGhostDrone;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'// IDENTIFICATION //'**
  String get authSubtitle;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get fieldPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginButton;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password? → RESET'**
  String get authForgotPassword;

  /// No description provided for @authToRegister.
  ///
  /// In en, this message translates to:
  /// **'New here? → SIGN UP'**
  String get authToRegister;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'// ACCESS RECOVERY //'**
  String get resetSubtitle;

  /// No description provided for @resetEmailLanguage.
  ///
  /// In en, this message translates to:
  /// **'EMAIL LANGUAGE'**
  String get resetEmailLanguage;

  /// No description provided for @resetSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get resetSendLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get resetLinkSent;

  /// No description provided for @resetDeviceLangKaz.
  ///
  /// In en, this message translates to:
  /// **'(device language: KAZ)'**
  String get resetDeviceLangKaz;

  /// No description provided for @resetDeviceLangRus.
  ///
  /// In en, this message translates to:
  /// **'(device language: RUS)'**
  String get resetDeviceLangRus;

  /// No description provided for @resetLangRus.
  ///
  /// In en, this message translates to:
  /// **'RUS'**
  String get resetLangRus;

  /// No description provided for @resetLangKaz.
  ///
  /// In en, this message translates to:
  /// **'KAZ'**
  String get resetLangKaz;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'// CREATE IDENTITY //'**
  String get registerSubtitle;

  /// No description provided for @registerNickLabel.
  ///
  /// In en, this message translates to:
  /// **'NICKNAME (optional)'**
  String get registerNickLabel;

  /// No description provided for @registerNickHint.
  ///
  /// In en, this message translates to:
  /// **'empty → Acid Raccoon'**
  String get registerNickHint;

  /// No description provided for @registerNickNote.
  ///
  /// In en, this message translates to:
  /// **'// otherwise a random cyber-nick on sign-up //'**
  String get registerNickNote;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? → LOGIN'**
  String get registerHaveAccount;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'// ANONYMOUS GEO-MESSENGER //'**
  String get splashSubtitle;

  /// No description provided for @splashEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'⦿  Enable location'**
  String get splashEnableLocation;

  /// No description provided for @splashLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get splashLogin;

  /// No description provided for @splashNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Sign up →'**
  String get splashNoAccount;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'GLOBAL CHAT'**
  String get chatTitle;

  /// No description provided for @chatYouTyped.
  ///
  /// In en, this message translates to:
  /// **'YOU TYPED'**
  String get chatYouTyped;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Message to global chat...'**
  String get chatInputHint;

  /// No description provided for @editIdentityEnterNick.
  ///
  /// In en, this message translates to:
  /// **'ENTER NICKNAME'**
  String get editIdentityEnterNick;

  /// No description provided for @editIdentityUpdated.
  ///
  /// In en, this message translates to:
  /// **'IDENTITY UPDATED'**
  String get editIdentityUpdated;

  /// No description provided for @editIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'CHANGE IDENTITY'**
  String get editIdentityTitle;

  /// No description provided for @editIdentityNickLabel.
  ///
  /// In en, this message translates to:
  /// **'NICKNAME'**
  String get editIdentityNickLabel;

  /// No description provided for @editIdentityNickHint.
  ///
  /// In en, this message translates to:
  /// **'Acid Raccoon'**
  String get editIdentityNickHint;

  /// No description provided for @editIdentityAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'AVATAR'**
  String get editIdentityAvatarLabel;

  /// No description provided for @geolocationTitle.
  ///
  /// In en, this message translates to:
  /// **'GEOLOCATION'**
  String get geolocationTitle;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get securityTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsConfigure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get settingsConfigure;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get settingsNotifications;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get settingsSecurity;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsLanguage;

  /// No description provided for @volumeLabel.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATION VOLUME'**
  String get volumeLabel;

  /// No description provided for @offlineMapsTitle.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE MAPS'**
  String get offlineMapsTitle;

  /// No description provided for @offlineMapsHint.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD MAP AREAS IN ADVANCE — IN THE FIELD WITHOUT CONNECTION TILES WILL BE TAKEN FROM CACHE.'**
  String get offlineMapsHint;

  /// No description provided for @offlineMapsSoon.
  ///
  /// In en, this message translates to:
  /// **'// SOON: SELECT A RECTANGLE ON THE MAP //'**
  String get offlineMapsSoon;

  /// No description provided for @offlineRegionNorth.
  ///
  /// In en, this message translates to:
  /// **'NORTH SECTOR'**
  String get offlineRegionNorth;

  /// No description provided for @offlineRegionBaseCamp.
  ///
  /// In en, this message translates to:
  /// **'BASE CAMP'**
  String get offlineRegionBaseCamp;

  /// No description provided for @offlineRegionSouthValley.
  ///
  /// In en, this message translates to:
  /// **'SOUTH VALLEY'**
  String get offlineRegionSouthValley;

  /// No description provided for @offlineRegionPolygonA7.
  ///
  /// In en, this message translates to:
  /// **'POLYGON A-7'**
  String get offlineRegionPolygonA7;

  /// No description provided for @offlineRegionCached.
  ///
  /// In en, this message translates to:
  /// **'{name} — CACHED'**
  String offlineRegionCached(String name);

  /// No description provided for @offlineRegionDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} — DELETED'**
  String offlineRegionDeleted(String name);

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'END SESSION AND LOG OUT OF YOUR ACCOUNT?'**
  String get logoutConfirm;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logoutButton;

  /// No description provided for @menuHeader.
  ///
  /// In en, this message translates to:
  /// **'// PROFILE · SYSTEM //'**
  String get menuHeader;

  /// No description provided for @menuFindUser.
  ///
  /// In en, this message translates to:
  /// **'FIND USER'**
  String get menuFindUser;

  /// No description provided for @menuChangeIdentity.
  ///
  /// In en, this message translates to:
  /// **'CHANGE IDENTITY'**
  String get menuChangeIdentity;

  /// No description provided for @menuChangePlan.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PLAN'**
  String get menuChangePlan;

  /// No description provided for @menuOfflineMaps.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE MAPS'**
  String get menuOfflineMaps;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get menuSettings;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get menuLogout;

  /// No description provided for @searchEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'ENTER EMAIL'**
  String get searchEnterEmail;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'FIND USER'**
  String get searchTitle;

  /// No description provided for @searchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'// SEARCH BY EXACT EMAIL //'**
  String get searchSubtitle;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @searchNotFound.
  ///
  /// In en, this message translates to:
  /// **'USER NOT FOUND'**
  String get searchNotFound;

  /// No description provided for @searchTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'TAP TO SELECT'**
  String get searchTapToSelect;

  /// No description provided for @searchSendGift.
  ///
  /// In en, this message translates to:
  /// **'SEND GIFT'**
  String get searchSendGift;

  /// No description provided for @mapStyleDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get mapStyleDark;

  /// No description provided for @mapStyleSatellite.
  ///
  /// In en, this message translates to:
  /// **'3D / Satellite'**
  String get mapStyleSatellite;

  /// No description provided for @mapStyleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get mapStyleMinimal;

  /// No description provided for @mapCloseAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Close app?'**
  String get mapCloseAppTitle;

  /// No description provided for @mapSignalsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} signals'**
  String mapSignalsCount(int count);

  /// No description provided for @mapPremiumHint.
  ///
  /// In en, this message translates to:
  /// **'🔒 Available in Premium — tap the plan to switch'**
  String get mapPremiumHint;

  /// No description provided for @messagePendingSync.
  ///
  /// In en, this message translates to:
  /// **'Awaiting upload to server'**
  String get messagePendingSync;

  /// No description provided for @messagePendingSyncAt.
  ///
  /// In en, this message translates to:
  /// **'⏳ awaiting sync · {time}'**
  String messagePendingSyncAt(String time);

  /// No description provided for @messageRepliesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String messageRepliesCount(int count);

  /// No description provided for @messageToChat.
  ///
  /// In en, this message translates to:
  /// **'TO CHAT →'**
  String get messageToChat;

  /// No description provided for @sendMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'NEW MESSAGE'**
  String get sendMessageTitle;

  /// No description provided for @sendMessageHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening here?'**
  String get sendMessageHint;

  /// No description provided for @sendMessageTtl.
  ///
  /// In en, this message translates to:
  /// **'TIME TO LIVE'**
  String get sendMessageTtl;

  /// No description provided for @sendAnonymously.
  ///
  /// In en, this message translates to:
  /// **'◉  Send anonymously'**
  String get sendAnonymously;

  /// No description provided for @sendPremiumHint.
  ///
  /// In en, this message translates to:
  /// **'🔒 Available in Premium (₸5000/mo)'**
  String get sendPremiumHint;

  /// No description provided for @decryptionInProgress.
  ///
  /// In en, this message translates to:
  /// **'[ DECRYPTING TRANSMISSION... ]'**
  String get decryptionInProgress;

  /// No description provided for @giftInsufficientStones.
  ///
  /// In en, this message translates to:
  /// **'NOT ENOUGH STONES'**
  String get giftInsufficientStones;

  /// No description provided for @giftSent.
  ///
  /// In en, this message translates to:
  /// **'GIFT SENT'**
  String get giftSent;

  /// No description provided for @giftCannotSendSelf.
  ///
  /// In en, this message translates to:
  /// **'CANNOT SEND TO YOURSELF'**
  String get giftCannotSendSelf;

  /// No description provided for @giftUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'USER NOT FOUND'**
  String get giftUserNotFound;

  /// No description provided for @stonesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'// IN-GAME CURRENCY //'**
  String get stonesSubtitle;

  /// No description provided for @stonesDescription.
  ///
  /// In en, this message translates to:
  /// **'Top up your Stones balance to send gifts in chat.'**
  String get stonesDescription;

  /// No description provided for @stonesRefreshStore.
  ///
  /// In en, this message translates to:
  /// **'REFRESH STORE'**
  String get stonesRefreshStore;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'PRICING PLAN'**
  String get planTitle;

  /// No description provided for @planMissingHint.
  ///
  /// In en, this message translates to:
  /// **'Open plans from the map'**
  String get planMissingHint;

  /// No description provided for @planToMap.
  ///
  /// In en, this message translates to:
  /// **'To map'**
  String get planToMap;

  /// No description provided for @planTestModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Test mode — switch the plan and instantly check all features'**
  String get planTestModeBanner;

  /// No description provided for @planBadgeHit.
  ///
  /// In en, this message translates to:
  /// **'HOT'**
  String get planBadgeHit;

  /// No description provided for @planBadgeActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get planBadgeActive;

  /// No description provided for @planSelect.
  ///
  /// In en, this message translates to:
  /// **'SELECT'**
  String get planSelect;

  /// No description provided for @planActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate {plan}'**
  String planActivate(String plan);

  /// No description provided for @planActivatedSnack.
  ///
  /// In en, this message translates to:
  /// **'Plan {plan} activated'**
  String planActivatedSnack(String plan);

  /// No description provided for @planFreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get planFreeSubtitle;

  /// No description provided for @planPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get planPremiumSubtitle;

  /// No description provided for @planEnterpriseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For teams and business'**
  String get planEnterpriseSubtitle;

  /// No description provided for @planFeatMsg5PerDay.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 messages per day'**
  String get planFeatMsg5PerDay;

  /// No description provided for @planFeatTtl1h.
  ///
  /// In en, this message translates to:
  /// **'TTL up to 1 hour'**
  String get planFeatTtl1h;

  /// No description provided for @planFeatStandardNick.
  ///
  /// In en, this message translates to:
  /// **'Standard nick on the map'**
  String get planFeatStandardNick;

  /// No description provided for @planFeatAnonMode.
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode'**
  String get planFeatAnonMode;

  /// No description provided for @planFeatTtl24h.
  ///
  /// In en, this message translates to:
  /// **'TTL up to 24 hours'**
  String get planFeatTtl24h;

  /// No description provided for @planFeatAvatarsGifts.
  ///
  /// In en, this message translates to:
  /// **'Avatars and gifts'**
  String get planFeatAvatarsGifts;

  /// No description provided for @planFeatTotemCompass.
  ///
  /// In en, this message translates to:
  /// **'Totem Compass'**
  String get planFeatTotemCompass;

  /// No description provided for @planFeatUnityGame.
  ///
  /// In en, this message translates to:
  /// **'Unity game'**
  String get planFeatUnityGame;

  /// No description provided for @planFeatPrivateZones.
  ///
  /// In en, this message translates to:
  /// **'Private zones'**
  String get planFeatPrivateZones;

  /// No description provided for @planFeatUnlimitedMsg.
  ///
  /// In en, this message translates to:
  /// **'Unlimited messages'**
  String get planFeatUnlimitedMsg;

  /// No description provided for @planFeatAnonShadow.
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode (Shadow_XXXX)'**
  String get planFeatAnonShadow;

  /// No description provided for @planFeatCustomAvatars.
  ///
  /// In en, this message translates to:
  /// **'Custom avatars'**
  String get planFeatCustomAvatars;

  /// No description provided for @planFeatGiftsToUsers.
  ///
  /// In en, this message translates to:
  /// **'Gifts to other users'**
  String get planFeatGiftsToUsers;

  /// No description provided for @planFeatApiIntegrations.
  ///
  /// In en, this message translates to:
  /// **'API integrations'**
  String get planFeatApiIntegrations;

  /// No description provided for @planFeatAllPremium.
  ///
  /// In en, this message translates to:
  /// **'Everything from Premium'**
  String get planFeatAllPremium;

  /// No description provided for @planFeatPrivateGeozones.
  ///
  /// In en, this message translates to:
  /// **'Private geozones'**
  String get planFeatPrivateGeozones;

  /// No description provided for @planFeatTeamChats.
  ///
  /// In en, this message translates to:
  /// **'Team chats'**
  String get planFeatTeamChats;

  /// No description provided for @planFeatActivityAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Activity analytics'**
  String get planFeatActivityAnalytics;

  /// No description provided for @planFeatWhiteLabel.
  ///
  /// In en, this message translates to:
  /// **'White-label branding'**
  String get planFeatWhiteLabel;

  /// No description provided for @planFeatPrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get planFeatPrioritySupport;

  /// No description provided for @planFeatE2eEncryption.
  ///
  /// In en, this message translates to:
  /// **'E2E encryption'**
  String get planFeatE2eEncryption;

  /// No description provided for @planFeatSlaGuarantees.
  ///
  /// In en, this message translates to:
  /// **'SLA guarantees'**
  String get planFeatSlaGuarantees;

  /// No description provided for @modeAnon.
  ///
  /// In en, this message translates to:
  /// **'ANON'**
  String get modeAnon;

  /// No description provided for @modeOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get modeOpen;

  /// No description provided for @unitMin.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMin;

  /// No description provided for @unitHour.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get unitHour;

  /// No description provided for @unitMb.
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get unitMb;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **' / mo'**
  String get perMonth;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}min'**
  String durationHoursMinutes(int h, int m);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m}min'**
  String durationMinutes(int m);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{s}s'**
  String durationSeconds(int s);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
