import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/data/prefs/user_prefs_service.dart';

abstract class ThemeEvent {
  const ThemeEvent();
}

class ThemeLoadEvent extends ThemeEvent {
  const ThemeLoadEvent();
}

class ThemeToggleEvent extends ThemeEvent {
  const ThemeToggleEvent();
}

abstract class ThemeState {
  const ThemeState();
}

class ThemeInitialState extends ThemeState {
  const ThemeInitialState();
}

class ThemeLoadedState extends ThemeState {
  final ThemeMode themeMode;

  const ThemeLoadedState(this.themeMode);
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final UserPrefsService _prefs;

  ThemeBloc(this._prefs) : super(const ThemeInitialState()) {
    on<ThemeLoadEvent>(_onLoad);
    on<ThemeToggleEvent>(_onToggle);
  }

  Future<void> _onLoad(ThemeLoadEvent event, Emitter<ThemeState> emit) async {
    try {
      final mode = await _prefs.getThemeMode();
      emit(ThemeLoadedState(mode));
    } catch (_) {
      emit(const ThemeLoadedState(ThemeMode.dark));
    }
  }

  Future<void> _onToggle(ThemeToggleEvent event, Emitter<ThemeState> emit) async {
    final current = state;
    if (current is! ThemeLoadedState) return;

    final next = current.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    try {
      await _prefs.setThemeMode(next);
      emit(ThemeLoadedState(next));
    } catch (_) {
      emit(current);
    }
  }
}
