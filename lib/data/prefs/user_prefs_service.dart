import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Тарифный план пользователя
enum UserPlan { free, premium, enterprise }

/// Стиль отображения карты
enum MapStyle { dark, satellite, minimal }

extension UserPlanX on UserPlan {
  String get label {
    switch (this) {
      case UserPlan.free:        return 'Free';
      case UserPlan.premium:     return 'Premium';
      case UserPlan.enterprise:  return 'Enterprise';
    }
  }

  bool get canUseAnonymous  => this != UserPlan.free;
  bool get canUseLongTtl    => this != UserPlan.free;
  bool get canUseGifts      => this != UserPlan.free;
  bool get canUsePrivateZone => this == UserPlan.enterprise;
  int  get dailyMessageLimit => this == UserPlan.free ? 5 : 999999;
  int  get maxTtlMinutes     => this == UserPlan.free ? 60 : 1440;
}

/// Локальные настройки пользователя
class UserPrefsService {
  static const _storage = FlutterSecureStorage();

  static const _keyAnon       = 'anon_mode';
  static const _keyPlan       = 'user_plan';
  static const _keyTtlMinutes = 'default_ttl_minutes';
  static const _keyMapStyle   = 'map_style';
  static const _keyThemeMode  = 'theme_mode';
  static const _keyLanguage   = 'app_language';

  static const supportedLanguageCodes = {'ru', 'en', 'kk'};
  static const defaultLanguageCode = 'en';

  // ── Анонимность ───────────────────────────────────────────────────────────

  Future<bool> getAnonMode() async {
    final v = await _storage.read(key: _keyAnon);
    return v == 'true';
  }

  Future<void> setAnonMode(bool value) async {
    await _storage.write(key: _keyAnon, value: value.toString());
  }

  // ── Тарифный план ─────────────────────────────────────────────────────────

  Future<UserPlan> getPlan() async {
    final v = await _storage.read(key: _keyPlan);
    switch (v) {
      case 'premium':    return UserPlan.premium;
      case 'enterprise': return UserPlan.enterprise;
      default:           return UserPlan.free;
    }
  }

  Future<void> setPlan(UserPlan plan) async {
    await _storage.write(key: _keyPlan, value: plan.name);
  }

  // Convenience — для обратной совместимости с MapBloc
  Future<bool> isPremium() async {
    final plan = await getPlan();
    return plan != UserPlan.free;
  }

  // ── TTL ───────────────────────────────────────────────────────────────────

  Future<int> getDefaultTtlMinutes() async {
    final v = await _storage.read(key: _keyTtlMinutes);
    return int.tryParse(v ?? '') ?? 60;
  }

  Future<void> setDefaultTtlMinutes(int minutes) async {
    await _storage.write(key: _keyTtlMinutes, value: minutes.toString());
  }

  Future<Duration> getDefaultTtl() async {
    final minutes = await getDefaultTtlMinutes();
    return Duration(minutes: minutes);
  }

  // ── Стиль карты ───────────────────────────────────────────────────────────

  Future<MapStyle> getMapStyle() async {
    final v = await _storage.read(key: _keyMapStyle);
    switch (v) {
      case 'satellite': return MapStyle.satellite;
      case 'minimal':   return MapStyle.minimal;
      default:          return MapStyle.dark;
    }
  }

  Future<void> setMapStyle(MapStyle style) async {
    await _storage.write(key: _keyMapStyle, value: style.name);
  }

  // ── Тема приложения ───────────────────────────────────────────────────────

  Future<ThemeMode> getThemeMode() async {
    final v = await _storage.read(key: _keyThemeMode);
    return v == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.light ? 'light' : 'dark';
    await _storage.write(key: _keyThemeMode, value: value);
  }

  Future<String?> getLanguageCode() async {
    return _storage.read(key: _keyLanguage);
  }

  Future<void> setLanguageCode(String code) async {
    await _storage.write(key: _keyLanguage, value: code);
  }
}
