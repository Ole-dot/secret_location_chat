import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';
import 'package:secret_location_chat/data/clan/clan_repository.dart';
import 'package:secret_location_chat/data/geo/geo_message_repository.dart';
import 'package:secret_location_chat/data/friends/friends_repository.dart';
import 'package:secret_location_chat/data/gifts/gift_repository.dart';
import 'package:secret_location_chat/data/models/user_model.dart';
import 'package:secret_location_chat/data/user/user_repository.dart';
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
import 'package:secret_location_chat/features/map/map_message_chat_launch_args.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_message_chat_cubit.dart';
import 'package:secret_location_chat/features/map/presentation/ui/map_message_chat_screen.dart';
import 'package:secret_location_chat/features/map/presentation/ui/map_screen.dart';
import 'package:secret_location_chat/features/minigame/presentation/ui/tetris_game_screen.dart';
import 'package:secret_location_chat/features/plan/presentation/ui/plan_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/edit_identity_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/geolocation_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/notifications_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/clan_cubit.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/security_cubit.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/clan_chat_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/user_profile_cubit.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/clan_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/user_profile_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/set_shared_target_map_screen.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/clan_chat_cubit.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/clan_map_cubit.dart';
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
      path: '/map-message/:messageId',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return const _AuthRequiredScreen(message: 'Войдите для чата сигнала');
        }
        final args = state.extra as MapMessageChatLaunchArgs?;
        if (args == null) {
          return const _AuthRequiredScreen(message: 'Сигнал не найден');
        }
        return BlocProvider(
          create: (_) => MapMessageChatCubit(
            repository: context.read<GeoMessageRepository>(),
            parentMessage: args.parentMessage,
            currentUserId: authState.user.uid,
            currentUsername: authState.user.username,
            isAnonymous: args.isAnonymous,
          ),
          child: const MapMessageChatScreen(),
        );
      },
    ),
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
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/geolocation', builder: (_, __) => const GeolocationScreen()),
    GoRoute(
      path: '/security',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return const _AuthRequiredScreen(message: 'Войдите для настроек безопасности');
        }
        return BlocProvider(
          create: (_) => SecurityCubit(
            authRepository: context.read<AuthRepository>(),
            email: authState.user.email,
          ),
          child: const SecurityScreen(),
        );
      },
    ),
    GoRoute(
      path: '/user/:uid',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return const _AuthRequiredScreen(message: 'Войдите для просмотра профиля');
        }
        final uid = state.pathParameters['uid'];
        if (uid == null || uid.isEmpty) {
          return const _AuthRequiredScreen(message: 'Пользователь не найден');
        }
        if (uid == authState.user.uid) {
          return const _AuthRequiredScreen(message: 'Это ваш профиль');
        }
        final cachedUser = state.extra as UserModel?;
        return _UserProfileRoute(
          currentUser: authState.user,
          targetUid: uid,
          cachedUser: cachedUser,
        );
      },
    ),
    GoRoute(
      path: '/clan',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return const _AuthRequiredScreen(message: 'Войдите для управления кланом');
        }
        return BlocProvider(
          create: (_) => ClanCubit(
            clanRepository: context.read<ClanRepository>(),
            userRepository: context.read<UserRepository>(),
            userId: authState.user.uid,
            ownerEmail: authState.user.email,
            ownerUsername: authState.user.username,
            ownerAvatar: authState.user.avatar,
          ),
          child: const ClanScreen(),
        );
      },
    ),
    GoRoute(
      path: '/clan/set-target',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return const _AuthRequiredScreen(message: 'Войдите для установки цели');
        }
        return BlocProvider(
          create: (ctx) => ClanMapCubit(
            repository: ctx.read<ClanRepository>(),
            userId: authState.user.uid,
          ),
          child: const SetSharedTargetMapScreen(),
        );
      },
    ),
    GoRoute(
      path: '/clan/chat/:chatId',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return const _AuthRequiredScreen(message: 'Войдите для семейного чата');
        }
        final chatId = state.pathParameters['chatId'];
        if (chatId == null || chatId.isEmpty) {
          return const _AuthRequiredScreen(message: 'Канал не найден');
        }
        final chatName = state.uri.queryParameters['name'] ?? 'Terminal';
        return BlocProvider(
          create: (_) => ClanChatCubit(
            repository: context.read<ClanRepository>(),
            userId: authState.user.uid,
            authorName: authState.user.username,
            chatId: chatId,
            chatName: Uri.decodeComponent(chatName),
          ),
          child: const ClanChatScreen(),
        );
      },
    ),
    GoRoute(
      path: '/stones-store',
      builder: (context, state) {
        final authState = context.read<AppAuthBloc>().state;
        if (authState is! AppAuthAuthenticatedState) {
          return const _AuthRequiredScreen(message: 'Войдите для покупки Стоунов');
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

class _UserProfileRoute extends StatelessWidget {
  final UserModel currentUser;
  final String targetUid;
  final UserModel? cachedUser;

  const _UserProfileRoute({
    required this.currentUser,
    required this.targetUid,
    this.cachedUser,
  });

  @override
  Widget build(BuildContext context) {
    if (cachedUser != null && cachedUser!.uid == targetUid) {
      return BlocProvider(
        create: (_) => UserProfileCubit(
          friendsRepository: context.read<FriendsRepository>(),
          currentUser: currentUser,
          targetUser: cachedUser!,
        ),
        child: const UserProfileScreen(),
      );
    }

    return FutureBuilder<UserModel?>(
      future: context.read<UserRepository>().getUserById(targetUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFF000000),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF0033),
                strokeWidth: 2,
              ),
            ),
          );
        }
        final targetUser = snapshot.data;
        if (targetUser == null) {
          return const _AuthRequiredScreen(message: 'Пользователь не найден');
        }
        return BlocProvider(
          create: (_) => UserProfileCubit(
            friendsRepository: context.read<FriendsRepository>(),
            currentUser: currentUser,
            targetUser: targetUser,
          ),
          child: const UserProfileScreen(),
        );
      },
    );
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
