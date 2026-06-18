import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/data/prefs/user_prefs_service.dart';

class LanguageState {
  final String languageCode;

  const LanguageState({required this.languageCode});
}

class LanguageInitialState extends LanguageState {
  const LanguageInitialState() : super(languageCode: UserPrefsService.defaultLanguageCode);
}

class LanguageLoadedState extends LanguageState {
  const LanguageLoadedState(String languageCode)
      : super(languageCode: languageCode);
}

class LanguageCubit extends Cubit<LanguageState> {
  final UserPrefsService _prefs;

  LanguageCubit(this._prefs) : super(const LanguageInitialState()) {
    loadSavedLanguage();
  }

  Future<void> loadSavedLanguage() async {
    try {
      final saved = await _prefs.getLanguageCode();
      if (saved != null &&
          UserPrefsService.supportedLanguageCodes.contains(saved)) {
        emit(LanguageLoadedState(saved));
        return;
      }

      final systemCode = WidgetsBinding.instance.platformDispatcher.locale
          .languageCode
          .toLowerCase();
      final resolved = UserPrefsService.supportedLanguageCodes.contains(systemCode)
          ? systemCode
          : UserPrefsService.defaultLanguageCode;

      await _prefs.setLanguageCode(resolved);
      emit(LanguageLoadedState(resolved));
    } catch (_) {
      emit(const LanguageLoadedState(UserPrefsService.defaultLanguageCode));
    }
  }

  Future<void> setLanguage(String code) async {
    final normalized = code.toLowerCase();
    if (!UserPrefsService.supportedLanguageCodes.contains(normalized)) {
      return;
    }
    await _prefs.setLanguageCode(normalized);
    emit(LanguageLoadedState(normalized));
  }
}
