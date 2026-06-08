import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/data/gifts/gift_repository.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/app/presentation/ui/video_splash_screen.dart';
import 'package:secret_location_chat/features/auth/presentation/ui/auth_screen.dart';
import 'package:secret_location_chat/features/auth/presentation/ui/password_reset_screen.dart';
import 'package:secret_location_chat/features/chat/global_chat_launch_args.dart';
import 'package:secret_location_chat/features/chat/presentation/ui/global_chat_screen.dart';
import 'package:secret_location_chat/features/gifts/gift_store_launch_args.dart';
import 'package:secret_location_chat/features/gifts/presentation/bloc/gift_store_cubit.dart';
import 'package:secret_location_chat/features/gifts/presentation/ui/gift_store_screen.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_bloc.dart';
import 'package:secret_location_chat/features/map/presentation/ui/map_screen.dart';
import 'package:secret_location_chat/features/minigame/presentation/ui/tetris_game_screen.dart';
import 'package:secret_location_chat/features/plan/presentation/ui/plan_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/edit_identity_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/geolocation_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/language_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/notifications_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/offline_maps_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/security_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/settings_screen.dart';
import 'package:secret_location_chat/features/register/presentation/ui/register_screen.dart';
import 'package:secret_location_chat/features/stones/presentation/ui/stones_store_screen.dart';

GoRouter buildRouter(AppAuthBloc authBloc) => GoRouter(
  initialLocation: '/splash',
  refreshListenable: _AuthStateNotifier(authBloc),
  redirect: (context, state) {
    final authState = authBloc.state;
    final loc = state.matchedLocation;
    final publicRoutes = ['/splash', '/auth', '/register', '/reset-password'];
    final isPublic = publicRoutes.contains(loc);

    if (authState is AppAuthUnauthenticatedState && !isPublic) {
      return '/splash';
    }
    if (authState is AppAuthAuthenticatedState && isPublic && loc != '/splash') {
      return '/map';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const VideoSplashScreen()),
    GoRoute(path: '/auth',   builder: (_, __) => const AuthScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/reset-password', builder: (_, __) => const PasswordResetScreen()),
    GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final args = state.extra as GlobalChatLaunchArgs?;
        if (args == null) {
          return Scaffold(
            body: Center(child: Text(AppLocalizations.of(context).authRequiredChat)),
          );
        }
        return GlobalChatScreen(args: args);
      },
    ),
    GoRoute(
      path: '/edit-identity',
      builder: (context, state) {
        final mapBloc = state.extra as MapBloc?;
        if (mapBloc != null) {
          return BlocProvider<MapBloc>.value(
            value: mapBloc,
            child: const EditIdentityScreen(),
          );
        }
        return const EditIdentityScreen();
      },
    ),
    GoRoute(path: '/offline-maps', builder: (_, __) => const OfflineMapsScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/geolocation', builder: (_, __) => const GeolocationScreen()),
    GoRoute(path: '/security', builder: (_, __) => const SecurityScreen()),
    GoRoute(path: '/language', builder: (_, __) => const LanguageScreen()),
    GoRoute(
      path: '/stones-store',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return _AuthRequiredScreen(message: AppLocalizations.of(context).authRequiredStones);
        }
        return const StonesStoreScreen();
      },
    ),
    GoRoute(
      path: '/gift-store',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return _AuthRequiredScreen(message: AppLocalizations.of(context).authRequiredGifts);
        }
        final args = state.extra as GiftStoreLaunchArgs? ?? const GiftStoreLaunchArgs();
        return BlocProvider(
          create: (_) => GiftStoreCubit(
            userId: authState.user.uid,
            nickname: authState.user.username,
            avatar: authState.user.avatar,
            giftRepository: context.read<GiftRepository>(),
          ),
          child: GiftStoreScreen(args: args),
        );
      },
    ),
    GoRoute(
      path: '/minigame',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return _AuthRequiredScreen(message: AppLocalizations.of(context).authRequiredTerminalHack);
        }
        return const TetrisGameScreen();
      },
    ),
    GoRoute(
      path: '/plan',
      builder: (context, state) {
        final mapBloc = state.extra as MapBloc?;
        if (mapBloc == null) {
          return const PlanScreenMissingBloc();
        }
        return BlocProvider<MapBloc>.value(
          value: mapBloc,
          child: const PlanScreen(),
        );
      },
    ),
  ],
);

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(AppAuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _AuthRequiredScreen extends StatelessWidget {
  final String message;

  const _AuthRequiredScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(message),
      ),
    );
  }
}
