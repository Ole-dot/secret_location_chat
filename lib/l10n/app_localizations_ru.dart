// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Secret Location Chat';

  @override
  String get commonBack => '← Назад';

  @override
  String get commonBackToLogin => '← Назад ко входу';

  @override
  String get commonCancel => 'ОТМЕНА';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonSend => 'Отправить';

  @override
  String get commonDelete => 'УДАЛИТЬ';

  @override
  String get commonDownload => 'СКАЧАТЬ';

  @override
  String get commonYes => 'Да';

  @override
  String get commonNo => 'Нет';

  @override
  String get authRequiredChat => 'Чат недоступен';

  @override
  String get authRequiredStones => 'Войдите для покупки Stones';

  @override
  String get authRequiredGifts => 'Войдите для отправки подарков';

  @override
  String get authRequiredTerminalHack => 'Войдите для TERMINAL HACK';

  @override
  String get errorGeneric => 'ПРОИЗОШЛА ОШИБКА. ПОПРОБУЙТЕ ПОЗЖЕ';

  @override
  String get errorNoConnection => 'НЕТ СВЯЗИ С СЕРВЕРОМ';

  @override
  String get errorUserNotFound => 'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН';

  @override
  String get errorWrongPassword => 'НЕВЕРНЫЙ ПАРОЛЬ';

  @override
  String get errorEmailInUse => 'АККАУНТ УЖЕ СУЩЕСТВУЕТ';

  @override
  String get errorInvalidEmail => 'НЕКОРРЕКТНЫЙ EMAIL';

  @override
  String get errorTooManyRequests => 'СЛИШКОМ МНОГО ПОПЫТОК. ПОПРОБУЙТЕ ПОЗЖЕ';

  @override
  String get errorWeakPassword => 'СЛИШКОМ СЛАБЫЙ ПАРОЛЬ';

  @override
  String get errorUserDisabled => 'АККАУНТ ЗАБЛОКИРОВАН';

  @override
  String get errorEmailSignInDisabled => 'ВХОД ЧЕРЕЗ EMAIL ОТКЛЮЧЁН';

  @override
  String get errorEnterEmail => 'ВВЕДИТЕ EMAIL';

  @override
  String get errorCreateAccountFailed => 'Не удалось создать аккаунт';

  @override
  String get errorGeoUnavailable => 'Геолокация недоступна';

  @override
  String get errorUserUnauthorized => 'ПОЛЬЗОВАТЕЛЬ НЕ АВТОРИЗОВАН';

  @override
  String get errorStoreUnavailable => 'МАГАЗИН НЕДОСТУПЕН';

  @override
  String get errorPurchaseFailed => 'ОШИБКА ПОКУПКИ';

  @override
  String get errorProfileNotFound => 'ПРОФИЛЬ НЕ НАЙДЕН';

  @override
  String get errorInvalidAmount => 'НЕВЕРНАЯ СУММА';

  @override
  String get validationInvalidEmail => 'Неверный формат email';

  @override
  String get validationPasswordMin => 'Минимум 6 символов';

  @override
  String get giftDescNeonRose => 'Цифровая роза с неоновым свечением';

  @override
  String get giftDescCyberCoffee => 'Горячий напиток из подпольного бара';

  @override
  String get giftDescDataCrystal => 'Редкий кристалл зашифрованных данных';

  @override
  String get giftDescGhostDrone => 'Мини-дрон для скрытой доставки';

  @override
  String get authTitle => 'ВХОД';

  @override
  String get authSubtitle => '// ИДЕНТИФИКАЦИЯ //';

  @override
  String get fieldPassword => 'ПАРОЛЬ';

  @override
  String get authLoginButton => 'Вход';

  @override
  String get authForgotPassword => 'Забыл пароль? → СБРОС';

  @override
  String get authToRegister => 'Зарегался? → РЕГАЙСЯ';

  @override
  String get resetTitle => 'СБРОС';

  @override
  String get resetSubtitle => '// ВОССТАНОВЛЕНИЕ ДОСТУПА //';

  @override
  String get resetEmailLanguage => 'ЯЗЫК ПИСЬМА';

  @override
  String get resetSendLink => 'Отправить ссылку';

  @override
  String get resetLinkSent => 'Ссылка для сброса пароля отправлена на email';

  @override
  String get resetDeviceLangKaz => '(язык устройства: ҚАЗ)';

  @override
  String get resetDeviceLangRus => '(язык устройства: РУС)';

  @override
  String get resetLangRus => 'РУС';

  @override
  String get resetLangKaz => 'ҚАЗ';

  @override
  String get registerTitle => 'РЕГАЙСЯ';

  @override
  String get registerSubtitle => '// СОЗДАЙ ЛИЧНОСТЬ //';

  @override
  String get registerNickLabel => 'НИК (необязательно)';

  @override
  String get registerNickHint => 'пусто → Кислотный Енот';

  @override
  String get registerNickNote =>
      '// иначе случайный кибер-ник при регистрации //';

  @override
  String get registerButton => 'Зарегался';

  @override
  String get registerHaveAccount => 'Уже есть аккаунт? → ВХОД';

  @override
  String get splashSubtitle => '// АНОНИМНЫЙ ГЕО-МЕССЕНДЖЕР //';

  @override
  String get splashEnableLocation => '⦿  Включить локацию';

  @override
  String get splashLogin => 'Войти';

  @override
  String get splashNoAccount => 'Нет аккаунта? Регайся →';

  @override
  String get chatTitle => 'ОБЩИЙ ЧАТ';

  @override
  String get chatYouTyped => 'ВЫ НАПЕЧАТАЛИ';

  @override
  String get chatInputHint => 'Сообщение в общий чат...';

  @override
  String get editIdentityEnterNick => 'ВВЕДИТЕ НИКНЕЙМ';

  @override
  String get editIdentityUpdated => 'ЛИЧНОСТЬ ОБНОВЛЕНА';

  @override
  String get editIdentityTitle => 'СМЕНИТЬ ЛИЧНОСТЬ';

  @override
  String get editIdentityNickLabel => 'НИКНЕЙМ';

  @override
  String get editIdentityNickHint => 'Кислотный Енот';

  @override
  String get editIdentityAvatarLabel => 'АВАТАР';

  @override
  String get geolocationTitle => 'ГЕОЛОКАЦИЯ';

  @override
  String get securityTitle => 'БЕЗОПАСНОСТЬ';

  @override
  String get notificationsTitle => 'УВЕДОМЛЕНИЯ';

  @override
  String get languageTitle => 'ЯЗЫК';

  @override
  String get settingsTitle => 'НАСТРОЙКИ';

  @override
  String get settingsConfigure => 'Настроить';

  @override
  String get settingsNotifications => 'УВЕДОМЛЕНИЯ';

  @override
  String get settingsSecurity => 'БЕЗОПАСНОСТЬ';

  @override
  String get settingsLanguage => 'ЯЗЫК';

  @override
  String get volumeLabel => 'ГРОМКОСТЬ УВЕДОМЛЕНИЙ';

  @override
  String get offlineMapsTitle => 'ОФФЛАЙН КАРТЫ';

  @override
  String get offlineMapsHint =>
      'СКАЧАЙТЕ УЧАСТКИ КАРТЫ ЗАРАНЕЕ — В ПОЛЕ БЕЗ СВЯЗИ ТАЙЛЫ БУДУТ БРАТЬСЯ ИЗ КЭША.';

  @override
  String get offlineMapsSoon => '// СКОРО: ВЫБОР ПРЯМОУГОЛЬНИКА НА КАРТЕ //';

  @override
  String get offlineRegionNorth => 'СЕВЕРНЫЙ УЧАСТОК';

  @override
  String get offlineRegionBaseCamp => 'БАЗОВЫЙ ЛАГЕРЬ';

  @override
  String get offlineRegionSouthValley => 'ЮЖНАЯ ДОЛИНА';

  @override
  String get offlineRegionPolygonA7 => 'ПОЛИГОН А-7';

  @override
  String offlineRegionCached(String name) {
    return '$name — В КЭШЕ';
  }

  @override
  String offlineRegionDeleted(String name) {
    return '$name — УДАЛЕНО';
  }

  @override
  String get logoutTitle => 'ВЫХОД';

  @override
  String get logoutConfirm => 'ЗАВЕРШИТЬ СЕАНС И ВЫЙТИ ИЗ АККАУНТА?';

  @override
  String get logoutButton => 'ВЫЙТИ';

  @override
  String get menuHeader => '// ПРОФИЛЬ · СИСТЕМА //';

  @override
  String get menuFindUser => 'НАЙТИ ПОЛЬЗОВАТЕЛЯ';

  @override
  String get menuChangeIdentity => 'СМЕНИТЬ ЛИЧНОСТЬ';

  @override
  String get menuChangePlan => 'СМЕНИТЬ ТАРИФ';

  @override
  String get menuOfflineMaps => 'ОФФЛАЙН КАРТЫ';

  @override
  String get menuSettings => 'НАСТРОЙКИ';

  @override
  String get menuLogout => 'ВЫХОД';

  @override
  String get searchEnterEmail => 'ВВЕДИТЕ EMAIL';

  @override
  String get searchTitle => 'НАЙТИ ПОЛЬЗОВАТЕЛЯ';

  @override
  String get searchSubtitle => '// ПОИСК ПО ТОЧНОМУ EMAIL //';

  @override
  String get searchButton => 'Искать';

  @override
  String get searchNotFound => 'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН';

  @override
  String get searchTapToSelect => 'НАЖМИТЕ, ЧТОБЫ ВЫБРАТЬ';

  @override
  String get searchSendGift => 'ОТПРАВИТЬ ПОДАРОК';

  @override
  String get mapStyleDark => 'Тёмная';

  @override
  String get mapStyleSatellite => '3D / Спутник';

  @override
  String get mapStyleMinimal => 'Минимал';

  @override
  String get mapCloseAppTitle => 'Закрыть приложение?';

  @override
  String mapSignalsCount(int count) {
    return '$count сигналов';
  }

  @override
  String get mapPremiumHint =>
      '🔒 Доступно в Premium — нажми на тариф чтобы сменить';

  @override
  String get messagePendingSync => 'Ожидает отправки на сервер';

  @override
  String messagePendingSyncAt(String time) {
    return '⏳ ожидает синхронизации · $time';
  }

  @override
  String messageRepliesCount(int count) {
    return '$count ответов';
  }

  @override
  String get messageToChat => 'В ЧАТ →';

  @override
  String get sendMessageTitle => 'НОВОЕ СООБЩЕНИЕ';

  @override
  String get sendMessageHint => 'Что происходит здесь?';

  @override
  String get sendMessageTtl => 'ВРЕМЯ ЖИЗНИ';

  @override
  String get sendAnonymously => '◉  Отправить анонимно';

  @override
  String get sendPremiumHint => '🔒 Доступно в Premium (₸5000/мес)';

  @override
  String get decryptionInProgress => '[ РАСШИФРОВКА ПЕРЕДАЧИ... ]';

  @override
  String get giftInsufficientStones => 'НЕДОСТАТОЧНО STONES';

  @override
  String get giftSent => 'ПОДАРОК ОТПРАВЛЕН';

  @override
  String get giftCannotSendSelf => 'НЕЛЬЗЯ ОТПРАВИТЬ СЕБЕ';

  @override
  String get giftUserNotFound => 'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН';

  @override
  String get stonesSubtitle => '// ВНУТРИИГРОВАЯ ВАЛЮТА //';

  @override
  String get stonesDescription =>
      'Пополните баланс Stones для отправки подарков в чате.';

  @override
  String get stonesRefreshStore => 'ОБНОВИТЬ МАГАЗИН';

  @override
  String get planTitle => 'ТАРИФНЫЙ ПЛАН';

  @override
  String get planMissingHint => 'Откройте тарифы с карты';

  @override
  String get planToMap => 'На карту';

  @override
  String get planTestModeBanner =>
      'Тестовый режим — смени план и сразу проверь все возможности';

  @override
  String get planBadgeHit => 'ХИТ';

  @override
  String get planBadgeActive => 'АКТИВЕН';

  @override
  String get planSelect => 'ВЫБРАТЬ';

  @override
  String planActivate(String plan) {
    return 'Активировать $plan';
  }

  @override
  String planActivatedSnack(String plan) {
    return 'Тариф $plan активирован';
  }

  @override
  String get planFreeSubtitle => 'Базовый';

  @override
  String get planPremiumSubtitle => 'Популярный';

  @override
  String get planEnterpriseSubtitle => 'Для команд и бизнеса';

  @override
  String get planFeatMsg5PerDay => 'До 5 сообщений в день';

  @override
  String get planFeatTtl1h => 'TTL максимум 1 час';

  @override
  String get planFeatStandardNick => 'Стандартный ник на карте';

  @override
  String get planFeatAnonMode => 'Анонимный режим';

  @override
  String get planFeatTtl24h => 'TTL до 24 часов';

  @override
  String get planFeatAvatarsGifts => 'Аватарки и подарки';

  @override
  String get planFeatTotemCompass => 'Totem Compass';

  @override
  String get planFeatUnityGame => 'Unity-игра';

  @override
  String get planFeatPrivateZones => 'Приватные зоны';

  @override
  String get planFeatUnlimitedMsg => 'Сообщений без лимита';

  @override
  String get planFeatAnonShadow => 'Анонимный режим (Shadow_XXXX)';

  @override
  String get planFeatCustomAvatars => 'Кастомные аватарки';

  @override
  String get planFeatGiftsToUsers => 'Подарки другим юзерам';

  @override
  String get planFeatApiIntegrations => 'API-интеграции';

  @override
  String get planFeatAllPremium => 'Всё из Premium';

  @override
  String get planFeatPrivateGeozones => 'Приватные геозоны';

  @override
  String get planFeatTeamChats => 'Командные чаты';

  @override
  String get planFeatActivityAnalytics => 'Аналитика активности';

  @override
  String get planFeatWhiteLabel => 'White-label оформление';

  @override
  String get planFeatPrioritySupport => 'Приоритетная поддержка';

  @override
  String get planFeatE2eEncryption => 'E2E шифрование';

  @override
  String get planFeatSlaGuarantees => 'SLA гарантии';

  @override
  String get modeAnon => 'АНОН';

  @override
  String get modeOpen => 'ОТКРЫТО';

  @override
  String get unitMin => 'мин';

  @override
  String get unitHour => 'ч';

  @override
  String get unitMb => 'МБ';

  @override
  String get perMonth => ' / мес';

  @override
  String durationHoursMinutes(int h, int m) {
    return '$hч $mмин';
  }

  @override
  String durationMinutes(int m) {
    return '$mмин';
  }

  @override
  String durationSeconds(int s) {
    return '$sс';
  }
}
