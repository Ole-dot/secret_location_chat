import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/map/map_tile_cache.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/theme_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';
import 'package:secret_location_chat/data/clan/clan_repository.dart';
import 'package:secret_location_chat/data/events/events_repository.dart';
import 'package:secret_location_chat/data/geo/geo_message_repository.dart';
import 'package:secret_location_chat/data/models/geo_message_model.dart';
import 'package:secret_location_chat/data/prefs/user_prefs_service.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';
import 'package:secret_location_chat/features/map/presentation/ui/map_message_chat_navigation.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/events_cubit.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/events_sheet_cubit.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_bloc.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/clan_map_cubit.dart';
import 'package:secret_location_chat/features/map/presentation/ui/message_card.dart';
import 'package:secret_location_chat/features/map/presentation/ui/send_message_sheet.dart';
import 'package:secret_location_chat/features/map/presentation/ui/widgets/events_bottom_sheet.dart';
import 'package:secret_location_chat/features/profile/presentation/ui/profile_menu_sheet.dart';
import 'package:secret_location_chat/core/constants/user_avatars.dart';

// ── URL тайлов для каждого стиля ──────────────────────────────────────────────

class _TileConfig {
  final String url;
  final String icon;
  const _TileConfig(this.url, this.icon);
}

const _tileConfigs = {
  MapStyle.dark: _TileConfig(
    'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    '◼',
  ),
  MapStyle.satellite: _TileConfig(
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    '⬡',
  ),
  MapStyle.minimal: _TileConfig(
    'https://basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png',
    '◻',
  ),
};

String _mapStyleLabel(AppLocalizations l10n, MapStyle style) {
  switch (style) {
    case MapStyle.dark:
      return l10n.mapStyleDark;
    case MapStyle.satellite:
      return l10n.mapStyleSatellite;
    case MapStyle.minimal:
      return l10n.mapStyleMinimal;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Builder(
        builder: (context) {
          final authState = context.watch<AppAuthBloc>().state;
          if (authState is! AppAuthAuthenticatedState) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.neonRed),
              ),
            );
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (ctx) => MapBloc(
                  msgRepo: ctx.read<GeoMessageRepository>(),
                  prefs: UserPrefsService(),
                  uid: authState.user.uid,
                  username: authState.user.username,
                )..add(MapInitEvent()),
              ),
              BlocProvider(
                create: (_) {
                  debugPrint(
                    '[MapScreen] creating EventsCubit uid=${authState.user.uid}',
                  );
                  return EventsCubit(
                    repository: EventsRepository(),
                    userId: authState.user.uid,
                  );
                },
              ),
              BlocProvider(
                create: (_) => EventsSheetCubit(),
              ),
              BlocProvider(
                create: (ctx) => ClanMapCubit(
                  repository: ctx.read<ClanRepository>(),
                  userId: authState.user.uid,
                ),
              ),
            ],
            child: const _MapBody(),
          );
        },
      ),
    );
  }
}

void _confirmExit(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.borderRed),
      ),
      title: Text(
        l10n.mapCloseAppTitle,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.commonNo, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            SystemNavigator.pop();
          },
          child: Text(
            l10n.commonYes,
            style: const TextStyle(color: AppColors.neonRed, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _MapBody extends StatefulWidget {
  const _MapBody();
  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  final _mapController = MapController();
  static const _defaultCenter = LatLng(43.2389, 76.9450);

  Future<void> _openProfileMenu(BuildContext context) async {
    final auth = context.read<AppAuthBloc>().state;
    if (auth is! AppAuthAuthenticatedState) return;

    var avatar = auth.user.avatar;
    var nickname = auth.user.username;
    final profile = await context.read<AuthRepository>().fetchUserProfile(auth.user.uid);
    if (profile != null) {
      avatar = profile.avatar;
      nickname = profile.username;
    }

    if (!context.mounted) return;
    await ProfileMenuSheet.show(
      context,
      nickname: nickname,
      avatarFileName: avatar,
      mapBloc: context.read<MapBloc>(),
    );
  }

  Future<void> _openMapMessageChat(BuildContext context, GeoMessage message) {
    final mapState = context.read<MapBloc>().state;
    return openMapMessageChat(
      context,
      messageId: message.id,
      cachedMessage: message,
      isAnonymous: mapState.isAnonymous,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _animatedFlyTo(LatLng dest, double zoom) async {
    final start = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;
    const steps = 24;
    const total = Duration(milliseconds: 550);

    for (var i = 1; i <= steps; i++) {
      if (!mounted) return;
      final t = Curves.easeInOutCubic.transform(i / steps);
      final lat = start.latitude + (dest.latitude - start.latitude) * t;
      final lng = start.longitude + (dest.longitude - start.longitude) * t;
      final z = startZoom + (zoom - startZoom) * t;
      _mapController.move(LatLng(lat, lng), z);
      await Future<void>.delayed(total ~/ steps);
    }
  }

  GeoMessage? _findGeoMessage(MapState state, String? geoMessageId) {
    if (geoMessageId == null) return null;
    for (final msg in state.messages) {
      if (msg.id == geoMessageId) return msg;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<MapBloc, MapState>(
          listenWhen: (prev, curr) =>
              prev.flyTarget?.sequence != curr.flyTarget?.sequence &&
              curr.flyTarget != null,
          listener: (context, state) async {
            final target = state.flyTarget;
            if (target == null) return;

            await _animatedFlyTo(
              LatLng(target.latitude, target.longitude),
              target.zoom,
            );
            if (!context.mounted) return;

            final match = _findGeoMessage(state, target.geoMessageId);
            if (match != null) {
              context.read<MapBloc>().add(MapSelectMessageEvent(match));
            }
            context.read<MapBloc>().add(MapClearFlyTargetEvent());
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (prev, curr) =>
              prev.isLoading && !curr.isLoading && curr.userPosition != null,
          listener: (context, state) {
            context.read<ClanMapCubit>().syncMemberLocation(
                  state.userPosition!.latitude,
                  state.userPosition!.longitude,
                );
            _mapController.move(
              LatLng(
                state.userPosition!.latitude,
                state.userPosition!.longitude,
              ),
              14,
            );
          },
        ),
        BlocListener<MapBloc, MapState>(
          listenWhen: (prev, curr) =>
              prev.error != curr.error && curr.error != null,
          listener: (context, state) {
            final error = state.error;
            if (error == null) return;
            CyberSnackBar.showError(
              context,
              l10nByKey(AppLocalizations.of(context), error),
              backgroundColor: AppColors.neonRedDark,
            );
          },
        ),
      ],
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
        final center = state.userPosition != null
            ? LatLng(state.userPosition!.latitude, state.userPosition!.longitude)
            : _defaultCenter;

        final tile = _tileConfigs[state.mapStyle]!;
        final l10n = AppLocalizations.of(context);
        final sheetPeek = MediaQuery.sizeOf(context).height * 0.1;

        return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                // ── КАРТА ────────────────────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 13,
                    minZoom: 3,
                    maxZoom: 19,
                    onTap: (_, __) => context.read<MapBloc>().add(MapSelectMessageEvent(null)),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tile.url,
                      userAgentPackageName: 'com.slc.app',
                      maxZoom: 19,
                      retinaMode: RetinaMode.isHighDensity(context),
                      fallbackUrl: 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      tileProvider: MapTileCache.store != null
                          ? CachedTileProvider(
                              store: MapTileCache.store!,
                              maxStale: const Duration(days: 30),
                            )
                          : null,
                    ),

                    // Тёмный оверлей поверх спутника — чтобы не было слишком ярко
                    if (state.mapStyle == MapStyle.satellite)
                      const ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Color(0x55000000),
                          BlendMode.darken,
                        ),
                        child: SizedBox.expand(),
                      ),

                    BlocBuilder<ClanMapCubit, ClanMapState>(
                      builder: (context, clanState) {
                        final target = clanState.sharedTarget;
                        final targetPoint = target == null
                            ? null
                            : LatLng(target.latitude, target.longitude);
                        final polylines = <Polyline>[];

                        if (targetPoint != null) {
                          if (state.userPosition != null) {
                            polylines.add(
                              Polyline(
                                points: [
                                  LatLng(
                                    state.userPosition!.latitude,
                                    state.userPosition!.longitude,
                                  ),
                                  targetPoint,
                                ],
                                color: const Color(0xFF39FF14),
                                strokeWidth: 2.5,
                              ),
                            );
                          }
                          for (final member in clanState.members) {
                            if (!member.hasLocation) continue;
                            polylines.add(
                              Polyline(
                                points: [
                                  LatLng(member.latitude!, member.longitude!),
                                  targetPoint,
                                ],
                                color: AppColors.neonRed.withValues(alpha: 0.7),
                                strokeWidth: 2,
                                borderColor: const Color(0xFF39FF14),
                                borderStrokeWidth: 0.5,
                              ),
                            );
                          }
                        }

                        return Stack(
                          children: [
                            if (polylines.isNotEmpty)
                              PolylineLayer(polylines: polylines),
                            MarkerLayer(
                              markers: [
                                if (state.userPosition != null)
                                  Marker(
                                    point: LatLng(
                                      state.userPosition!.latitude,
                                      state.userPosition!.longitude,
                                    ),
                                    width: 22,
                                    height: 22,
                                    child: _UserMarker(),
                                  ),
                                if (targetPoint != null)
                                  Marker(
                                    point: targetPoint,
                                    width: 40,
                                    height: 40,
                                    child: const _SharedTargetMarker(),
                                  ),
                                ...state.messages.map((msg) => Marker(
                                      point: LatLng(msg.latitude, msg.longitude),
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.bottomCenter,
                                      child: _MsgMarker(
                                        message: msg,
                                        isSelected:
                                            state.selectedMessage?.id == msg.id,
                                        onTap: () => _openMapMessageChat(
                                          context,
                                          msg,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const RichAttributionWidget(
                      attributions: [TextSourceAttribution('© CARTO / ArcGIS / OSM')],
                    ),
                  ],
                ),

                // ── HUD ВЕРХНИЙ ───────────────────────────────────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Row(
                      children: [
                        // Аватар / лев — меню профиля
                        GestureDetector(
                          onTap: () => _openProfileMenu(context),
                          child: _HudAvatarBox(
                            avatarFileName: _resolveAvatar(context),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Тариф — нажать, чтобы сменить
                        GestureDetector(
                          onTap: () => context.push(
                            '/plan',
                            extra: context.read<MapBloc>(),
                          ),
                          child: _HudBox(
                            borderColor: _planColor(state.plan),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium_outlined, color: _planColor(state.plan), size: 12),
                                const SizedBox(width: 4),
                                Text(state.plan.label.toUpperCase(),
                                  style: TextStyle(color: _planColor(state.plan), fontSize: 10,
                                    letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Стиль карты — переключалка
                        GestureDetector(
                          onTap: () => context.read<MapBloc>().add(MapCycleStyleEvent()),
                          child: _HudBox(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tile.icon, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                                const SizedBox(width: 5),
                                Text(_mapStyleLabel(l10n, state.mapStyle),
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 1)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        BlocBuilder<ThemeBloc, ThemeState>(
                          builder: (context, themeState) {
                            final isDark = themeState is ThemeLoadedState
                                ? themeState.themeMode == ThemeMode.dark
                                : true;
                            return GestureDetector(
                              onTap: () => context
                                  .read<ThemeBloc>()
                                  .add(const ThemeToggleEvent()),
                              child: _HudBox(
                                borderColor: isDark
                                    ? AppColors.border
                                    : AppColors.neonRed.withValues(alpha: 0.5),
                                child: Icon(
                                  isDark
                                      ? Icons.dark_mode_outlined
                                      : Icons.light_mode_outlined,
                                  color: AppColors.neonRed,
                                  size: 14,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 8),

                        // Анонимность
                        GestureDetector(
                          onTap: () {
                            if (!state.isPremium) {
                              _showPremiumHint(context);
                              return;
                            }
                            context.read<MapBloc>().add(MapToggleAnonEvent());
                          },
                          child: _HudBox(
                            borderColor: state.isAnonymous ? AppColors.neonRed : AppColors.border,
                            bgColor: state.isAnonymous ? AppColors.neonRed.withValues(alpha: 0.15) : null,
                            child: Text(
                              state.isAnonymous ? '◉ ${l10n.modeAnon}' : '○ ${l10n.modeOpen}',
                              style: TextStyle(
                                color: state.isAnonymous ? AppColors.neonRed : AppColors.textSecondary,
                                fontSize: 10, letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),

                // ── КАРТОЧКА СООБЩЕНИЯ ────────────────────────────────────────
                if (state.selectedMessage != null)
                  Positioned(
                    left: 0, right: 0, bottom: sheetPeek + 12,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                        child: child,
                      ),
                      child: MessageCard(
                        key: ValueKey(state.selectedMessage!.id),
                        message: state.selectedMessage!,
                        onClose: () => context.read<MapBloc>().add(MapSelectMessageEvent(null)),
                        onReply: () {},
                        onOpenChat: () => _openMapMessageChat(
                          context,
                          state.selectedMessage!,
                        ),
                      ),
                    ),
                  ),

                // ── Загрузка ──────────────────────────────────────────────────
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator(color: AppColors.neonRed)),

                // ── Счётчик сообщений (внизу слева) ──────────────────────────
                Positioned(
                  left: 12,
                  bottom: sheetPeek + 8,
                  child: _HudBox(
                    child: Text(l10n.mapSignalsCount(state.messages.length),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  ),
                ),

                const EventsBottomSheet(),
              ],
            ),

            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Центрировать на себе
                if (state.userPosition != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FloatingActionButton.small(
                      heroTag: 'center',
                      backgroundColor: AppColors.surface,
                      elevation: 0,
                      onPressed: () => _mapController.move(
                        LatLng(state.userPosition!.latitude, state.userPosition!.longitude), 15,
                      ),
                      child: const Icon(Icons.my_location, color: AppColors.textSecondary, size: 18),
                    ),
                  ),

                // Написать сообщение
                FloatingActionButton(
                  heroTag: 'write',
                  backgroundColor: AppColors.neonRed,
                  elevation: 4,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<MapBloc>(),
                      child: const SendMessageSheet(),
                    ),
                  ),
                  child: const Icon(Icons.add, color: AppColors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _resolveAvatar(BuildContext context) {
    final auth = context.watch<AppAuthBloc>().state;
    if (auth is AppAuthAuthenticatedState) return auth.user.avatar;
    return kUserAvatarFiles.first;
  }

  void _showPremiumHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.surfaceCard,
      content: Text(AppLocalizations.of(context).mapPremiumHint,
        style: const TextStyle(color: AppColors.neonRed)),
    ));
  }

  Color _planColor(UserPlan plan) {
    switch (plan) {
      case UserPlan.free:        return AppColors.textSecondary;
      case UserPlan.premium:     return AppColors.neonRed;
      case UserPlan.enterprise:  return const Color(0xFF7F77DD);
    }
  }
}

// ── Вспомогательные виджеты ───────────────────────────────────────────────────

class _HudAvatarBox extends StatelessWidget {
  final String avatarFileName;

  const _HudAvatarBox({required this.avatarFileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neonRed, width: 1.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: AppColors.neonRedGlow, blurRadius: 10, spreadRadius: 0),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          userAvatarAssetPath(avatarFileName),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text(
              'SLC',
              style: TextStyle(
                color: AppColors.neonRed,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HudBox extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? bgColor;
  const _HudBox({required this.child, this.borderColor, this.bgColor});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor ?? AppColors.background.withValues(alpha: 0.88),
      border: Border.all(color: borderColor ?? AppColors.border),
      borderRadius: BorderRadius.circular(4),
    ),
    child: child,
  );
}

class _UserMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.neonRed,
      boxShadow: [BoxShadow(color: AppColors.neonRedGlow, blurRadius: 10, spreadRadius: 2)],
    ),
  );
}

class _SharedTargetMarker extends StatelessWidget {
  const _SharedTargetMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF39FF14).withValues(alpha: 0.25),
        border: Border.all(color: const Color(0xFF39FF14), width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x8039FF14), blurRadius: 14, spreadRadius: 2),
        ],
      ),
      child: const Icon(
        Icons.radar,
        color: Color(0xFF39FF14),
        size: 22,
      ),
    );
  }
}

class _MsgMarker extends StatelessWidget {
  final GeoMessage message;
  final bool isSelected;
  final VoidCallback onTap;

  const _MsgMarker({required this.message, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ttl = message.ttlProgress;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.35 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Stack(alignment: Alignment.center, children: [
          Icon(
            message.isAnonymous ? Icons.visibility_off : Icons.location_on,
            color: message.isAnonymous
                ? AppColors.neonRed
                : Color.lerp(Colors.orange, AppColors.neonRed, 1 - ttl)!,
            size: 32,
            shadows: const [Shadow(color: Color(0x66FF0033), blurRadius: 6)],
          ),
          if (message.isPendingSync)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Icon(
                  Icons.schedule,
                  size: 12,
                  color: Colors.orange.shade300,
                ),
              ),
            ),
          if (ttl < 0.3 && !message.isPendingSync)
            Positioned(
              top: 6,
              child: Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                  boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 4)],
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
