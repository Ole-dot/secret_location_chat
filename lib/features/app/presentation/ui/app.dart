import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/localization/language_cubit.dart';
import 'package:secret_location_chat/core/router/router.dart';
import 'package:secret_location_chat/core/theme/app_theme.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';
import 'package:secret_location_chat/data/gifts/gift_repository.dart';
import 'package:secret_location_chat/data/prefs/user_prefs_service.dart';
import 'package:secret_location_chat/data/stones/stones_repository.dart';
import 'package:secret_location_chat/data/user/user_repository.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/theme_bloc.dart';
import 'package:secret_location_chat/features/stones/presentation/bloc/stones_cubit.dart';

class SlcApp extends StatefulWidget {
  const SlcApp({super.key});

  @override
  State<SlcApp> createState() => _SlcAppState();
}

class _SlcAppState extends State<SlcApp> {
  late final AuthRepository _authRepo;
  late final UserRepository _userRepo;
  late final StonesRepository _stonesRepo;
  late final GiftRepository _giftRepo;
  late final UserPrefsService _prefs;
  late final AppAuthBloc _authBloc;
  late final ThemeBloc _themeBloc;
  late final LanguageCubit _languageCubit;
  late final GoRouter _router;
  StonesCubit? _stonesCubit;
  StreamSubscription<AppAuthState>? _authSub;
  String? _stonesUserId;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepository();
    _userRepo = UserRepository();
    _stonesRepo = StonesRepository();
    _giftRepo = GiftRepository();
    _prefs = UserPrefsService();
    _authBloc = AppAuthBloc(_authRepo)..add(AppAuthCheckEvent());
    _themeBloc = ThemeBloc(_prefs)..add(const ThemeLoadEvent());
    _languageCubit = LanguageCubit(_prefs);
    _router = buildRouter(_authBloc);
    _authSub = _authBloc.stream.listen(_syncStonesCubit);
    _syncStonesCubit(_authBloc.state);
  }

  void _syncStonesCubit(AppAuthState state) {
    if (state is AppAuthAuthenticatedState) {
      if (_stonesUserId == state.user.uid && _stonesCubit != null) return;
      _stonesCubit?.close();
      _stonesUserId = state.user.uid;
      _stonesCubit = StonesCubit.balanceOnly(
        userId: state.user.uid,
        repository: _stonesRepo,
      );
    } else {
      _stonesCubit?.close();
      _stonesCubit = null;
      _stonesUserId = null;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _stonesCubit?.close();
    _authBloc.close();
    _themeBloc.close();
    _languageCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authRepo),
        RepositoryProvider.value(value: _userRepo),
        RepositoryProvider.value(value: _stonesRepo),
        RepositoryProvider.value(value: _giftRepo),
        RepositoryProvider.value(value: _prefs),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authBloc),
          BlocProvider.value(value: _themeBloc),
          BlocProvider.value(value: _languageCubit),
          if (_stonesCubit != null) BlocProvider.value(value: _stonesCubit!),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final themeMode = themeState is ThemeLoadedState
                ? themeState.themeMode
                : ThemeMode.dark;

            return BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, languageState) {
                return MaterialApp.router(
                  title: 'Secret Location Chat',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: Locale(languageState.languageCode),
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('ru'),
                    Locale('en'),
                    Locale('kk'),
                  ],
                  routerConfig: _router,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
