import 'package:timeago/timeago.dart' as timeago;

/// Registers [timeago] locales used by the app (en + ru).
void initTimeagoLocales() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('ru', timeago.RuMessages());
}

/// Maps app [languageCode] to a supported timeago locale (defaults to English).
String timeagoLocaleFor(String languageCode) {
  return languageCode == 'ru' ? 'ru' : 'en';
}

String? formatRelativeTimestamp(
  DateTime? dateTime,
  String languageCode,
) {
  if (dateTime == null) return null;
  return timeago.format(
    dateTime,
    locale: timeagoLocaleFor(languageCode),
  );
}
