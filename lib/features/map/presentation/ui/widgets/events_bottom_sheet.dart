import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/audio/audio_service.dart';
import 'package:secret_location_chat/core/layout/view_insets.dart';
import 'package:secret_location_chat/core/localization/events_l10n.dart';
import 'package:secret_location_chat/core/localization/language_cubit.dart';
import 'package:secret_location_chat/core/localization/timeago_config.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';
import 'package:secret_location_chat/data/models/user_log_event.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/events_cubit.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/events_sheet_cubit.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_bloc.dart';
import 'package:secret_location_chat/features/map/presentation/ui/map_message_chat_navigation.dart';
import 'package:secret_location_chat/features/map/presentation/ui/widgets/burning_message_wrapper.dart';
import 'package:secret_location_chat/features/map/presentation/ui/widgets/cyber_decryption_text.dart';
import 'package:secret_location_chat/features/map/presentation/ui/widgets/network_requests_tab.dart';
import 'package:secret_location_chat/features/app/presentation/bloc/app_auth_bloc.dart';

class EventsBottomSheet extends StatefulWidget {
  const EventsBottomSheet({super.key});

  @override
  State<EventsBottomSheet> createState() => _EventsBottomSheetState();
}

class _EventsBottomSheetState extends State<EventsBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChanged);
  }

  void _collapseSheet() {
    if (!_sheetController.isAttached) return;
    _sheetController.animateTo(
      EventsSheetCubit.collapsedSize,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _flyToEvent(BuildContext context, UserLogEvent event) {
    if (!event.hasLocation) return;
    context.read<EventsSheetCubit>().requestCollapse();
    context.read<MapBloc>().add(
          MapFlyToEvent(
            latitude: event.latitude!,
            longitude: event.longitude!,
            geoMessageId: event.geoMessageDocumentId,
          ),
        );
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<EventsSheetCubit, int>(
      listener: (context, _) => _collapseSheet(),
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: EventsSheetCubit.collapsedSize,
        minChildSize: EventsSheetCubit.collapsedSize,
        maxChildSize: 0.8,
        snap: true,
        snapSizes: const [0.1, 0.45, 0.8],
        builder: (context, scrollController) {
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.94),
              border: Border.all(color: AppColors.neonRed, width: 1.2),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.neonRedGlow,
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: BlocBuilder<EventsCubit, EventsState>(
              builder: (context, state) {
                final authState = context.watch<AppAuthBloc>().state;
                final userId = authState is AppAuthAuthenticatedState
                    ? authState.user.uid
                    : null;

                final tabSlivers = switch (_tabController.index) {
                  0 => _buildGlobalSlivers(context, state, l10n),
                  1 => _buildMyLogsSlivers(context, state, l10n),
                  _ => <Widget>[],
                };

                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _GrabHandle(label: l10n.eventsPullUp),
                    ),
                    SliverToBoxAdapter(
                      child: _SheetHeader(title: l10n.eventsTerminalTitle),
                    ),
                    SliverToBoxAdapter(
                      child: _EventsTabBar(
                        controller: _tabController,
                        globalLabel: l10n.eventsTabGlobal,
                        myLogsLabel: l10n.eventsTabMyLogs,
                        networkLabel: l10n.eventsTabNetwork,
                      ),
                    ),
                    if (_tabController.index == 2)
                      userId == null
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: NetworkRequestsEmptyPanel(
                                label: l10n.eventsNetworkEmpty,
                              ),
                            )
                          : NetworkRequestsTabSliver(userId: userId)
                    else
                      ...tabSlivers,
                  ],
                );
              },
            ),
          ),
        );
      },
      ),
    );
  }

  List<Widget> _buildGlobalSlivers(
    BuildContext context,
    EventsState state,
    AppLocalizations l10n,
  ) {
    return _buildTabSlivers(
      context: context,
      isLoading: state.globalLoading,
      globalEvents: state.visibleGlobalLogs,
      error: state.globalError,
      emptyLabel: l10n.eventsGlobalEmpty,
      replyPrefix: l10n.eventsReplyPrefix,
    );
  }

  List<Widget> _buildMyLogsSlivers(
    BuildContext context,
    EventsState state,
    AppLocalizations l10n,
  ) {
    return _buildTabSlivers(
      context: context,
      isLoading: state.myLogsLoading,
      myLogs: state.visibleMyLogs,
      error: state.myLogsError,
      warning: state.myLogsWarning,
      emptyLabel: l10n.eventsMyLogsEmpty,
      isMyLogs: true,
      replyPrefix: l10n.eventsReplyPrefix,
    );
  }

  List<Widget> _buildTabSlivers({
    required BuildContext context,
    required bool isLoading,
    List<UserLogEvent> globalEvents = const [],
    List<UserLogEvent> myLogs = const [],
    required String? error,
    required String emptyLabel,
    String? warning,
    bool isMyLogs = false,
    String replyPrefix = '',
  }) {
    if (isLoading) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.neonRed,
              strokeWidth: 2,
            ),
          ),
        ),
      ];
    }

    final errorText = error;
    if (errorText != null && errorText.isNotEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EventsErrorPanel(message: errorText),
        ),
      ];
    }

    final warningText = warning;
    final visibleCount = isMyLogs ? myLogs.length : globalEvents.length;
    if (visibleCount == 0 &&
        warningText != null &&
        warningText.isNotEmpty &&
        isEventsNetworkError(warningText)) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EventsErrorPanel(message: warningText),
        ),
      ];
    }

    if (visibleCount == 0) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _EventsEmptyPanel(
            label: emptyLabel,
            warning: warningText,
          ),
        ),
      ];
    }

    final listBottomPadding = 16.0 + systemBottomInset(context);

    if (isMyLogs) {
      final hasWarning = warningText != null && warningText.isNotEmpty;
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, listBottomPadding),
          sliver: SliverList.separated(
            itemCount: myLogs.length + (hasWarning ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (hasWarning && index == 0) {
                return _MyLogsWarning(warning: warningText);
              }
              final offset = hasWarning ? 1 : 0;
              final logIndex = index - offset;
              if (logIndex < 0 || logIndex >= myLogs.length) {
                return const SizedBox.shrink();
              }
              final log = myLogs[logIndex];
              return BurningMessageWrapper(
                key: ValueKey(log.id),
                message: log,
                onBurnComplete: () => context
                    .read<EventsCubit>()
                    .markMyLogBurned(log.id),
                child: _MyLogTerminalEntry(
                  message: log,
                  replyPrefix: replyPrefix,
                  onTap: log.geoMessageDocumentId != null
                      ? () => openMapMessageChatFromLog(context, log)
                      : null,
                  onFlyTo: log.hasLocation
                      ? () => _flyToEvent(context, log)
                      : null,
                ),
              );
            },
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, listBottomPadding),
        sliver: SliverList.separated(
          itemCount: globalEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index < 0 || index >= globalEvents.length) {
              return const SizedBox.shrink();
            }
            final event = globalEvents[index];
            return BurningMessageWrapper(
              key: ValueKey(event.id),
              message: event,
              onBurnComplete: () => context
                  .read<EventsCubit>()
                  .markGlobalEventBurned(event.id),
              child: _MyLogTerminalEntry(
                message: event,
                replyPrefix: replyPrefix,
                onTap: event.geoMessageDocumentId != null
                    ? () => openMapMessageChatFromLog(context, event)
                    : null,
                onFlyTo: event.hasLocation
                    ? () => _flyToEvent(context, event)
                    : null,
              ),
            );
          },
        ),
      ),
    ];
  }
}

class _EventsErrorPanel extends StatelessWidget {
  final String message;

  const _EventsErrorPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rawMessage = eventsRawFirebaseMessage(message);
    final headline = resolveEventsErrorMessage(l10n, message);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber, color: AppColors.neonRed, size: 32),
            const SizedBox(height: 14),
            Text(
              l10n.eventsSignalLost,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.neonRed,
                fontFamily: 'monospace',
                letterSpacing: 2,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (headline != rawMessage) ...[
              const SizedBox(height: 10),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                  letterSpacing: 0.8,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SelectableText(
              rawMessage,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: AppColors.neonRed,
                fontFamily: 'monospace',
                letterSpacing: 0.4,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsEmptyPanel extends StatelessWidget {
  final String label;
  final String? warning;

  const _EventsEmptyPanel({
    required this.label,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    final warningText = warning;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (warningText != null && warningText.isNotEmpty) ...[
              _MyLogsWarning(warning: warningText),
              const SizedBox(height: 16),
            ],
            const Icon(
              Icons.sensors_off,
              color: AppColors.textDisabled,
              size: 28,
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontFamily: 'monospace',
                letterSpacing: 2.5,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrabHandle extends StatelessWidget {
  final String label;

  const _GrabHandle({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neonRed.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(color: AppColors.neonRedGlow, blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;

  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.terminal, color: AppColors.neonRed, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsTabBar extends StatelessWidget {
  final TabController controller;
  final String globalLabel;
  final String myLogsLabel;
  final String networkLabel;

  const _EventsTabBar({
    required this.controller,
    required this.globalLabel,
    required this.myLogsLabel,
    required this.networkLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderRed),
      ),
      child: TabBar(
        controller: controller,
        onTap: (_) => AudioService.instance.playClick(),
        indicator: BoxDecoration(
          color: AppColors.neonRed.withValues(alpha: 0.15),
          border: Border(
            bottom: BorderSide(color: AppColors.neonRed, width: 2),
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.neonRed,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontSize: 10,
        ),
        tabs: [
          Tab(text: globalLabel),
          Tab(text: myLogsLabel),
          Tab(text: networkLabel),
        ],
      ),
    );
  }
}

class _MyLogsWarning extends StatelessWidget {
  final String warning;

  const _MyLogsWarning({required this.warning});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rawMessage = eventsRawFirebaseMessage(warning);
    final display = isEventsNetworkError(warning)
        ? resolveEventsErrorMessage(l10n, warning)
        : warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x33FF0033),
        border: Border.all(color: AppColors.neonRed),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, color: AppColors.neonRed, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              isEventsNetworkError(warning) ? rawMessage : display,
              style: const TextStyle(
                color: AppColors.neonRed,
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelativeTimestamp extends StatefulWidget {
  final DateTime? timestamp;
  final TextStyle style;

  const _RelativeTimestamp({
    required this.timestamp,
    required this.style,
  });

  @override
  State<_RelativeTimestamp> createState() => _RelativeTimestampState();
}

class _RelativeTimestampState extends State<_RelativeTimestamp> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = context.watch<LanguageCubit>().state.languageCode;
    final relative = formatRelativeTimestamp(
      widget.timestamp,
      languageCode,
    );
    final label = relative ?? l10n.eventsTimestampUnavailable;

    return Text(
      '[$label]',
      style: widget.style,
    );
  }
}

class _MyLogTerminalEntry extends StatelessWidget {
  final UserLogEvent message;
  final String replyPrefix;
  final VoidCallback? onTap;
  final VoidCallback? onFlyTo;

  const _MyLogTerminalEntry({
    required this.message,
    required this.replyPrefix,
    this.onTap,
    this.onFlyTo,
  });

  bool get _isReply => message.type == UserLogType.reply;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        _isReply ? const Color(0xFF8A2BE2) : const Color(0xFF39FF14);
    final icon = _isReply ? Icons.reply_rounded : Icons.radar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(
          color: onTap != null ? AppColors.borderRed : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            child: LinearProgressIndicator(
              value: message.ttlProgress,
              minHeight: 2,
              backgroundColor: AppColors.border,
              color: message.ttlProgress > 0.3 ? iconColor : Colors.orange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 13),
              const SizedBox(width: 6),
              _RelativeTimestamp(
                timestamp: message.timestamp,
                style: TextStyle(
                  color: iconColor,
                  fontFamily: 'monospace',
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.authorName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (message.isPendingSync)
                const Icon(Icons.schedule, color: Colors.orange, size: 12),
              if (onFlyTo != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onFlyTo,
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.neonRed,
                    size: 14,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return CyberDecryptionText(
                text: _isReply ? '$replyPrefix${message.text}' : message.text,
                targetLanguageCode: languageState.languageCode,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.35,
                ),
              );
            },
          ),
              ],
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
