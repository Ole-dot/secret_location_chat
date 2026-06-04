import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/localization/language_cubit.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/data/models/chat_message_model.dart';
import 'package:secret_location_chat/data/models/user_log_event.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/events_cubit.dart';
import 'package:secret_location_chat/features/map/presentation/ui/widgets/cyber_decryption_text.dart';

class EventsBottomSheet extends StatelessWidget {
  const EventsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
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
            child: DefaultTabController(
              length: 2,
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(child: const _GrabHandle()),
                  const SliverToBoxAdapter(child: _SheetHeader()),
                  const SliverToBoxAdapter(child: _EventsTabBar()),
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: BlocBuilder<EventsCubit, EventsState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.neonRed,
                              strokeWidth: 2,
                            ),
                          );
                        }

                        return TabBarView(
                          children: [
                            _EventsLogList(
                              logs: state.globalLogs,
                              error: state.globalError,
                              emptyLabel: 'NO GLOBAL EVENTS',
                            ),
                            _MyLogsList(
                              logs: state.myLogs,
                              error: state.myLogsError,
                              warning: state.myLogsWarning,
                              emptyLabel: 'NO PERSONAL LOGS',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

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
            const Text(
              'PULL UP · EVENTS',
              style: TextStyle(
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
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.terminal, color: AppColors.neonRed, size: 16),
          const SizedBox(width: 8),
          const Text(
            'EVENTS TERMINAL',
            style: TextStyle(
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
  const _EventsTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderRed),
      ),
      child: TabBar(
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
          letterSpacing: 2,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
          fontSize: 11,
        ),
        tabs: const [
          Tab(text: 'GLOBAL'),
          Tab(text: 'MY LOGS'),
        ],
      ),
    );
  }
}

class _EventsLogList extends StatelessWidget {
  final List<ChatMessage> logs;
  final String? error;
  final String emptyLabel;

  const _EventsLogList({
    required this.logs,
    required this.error,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.warning_amber, color: AppColors.neonRed, size: 28),
          const SizedBox(height: 12),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.neonRed,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    if (logs.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Text(
              emptyLabel,
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontFamily: 'monospace',
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      itemCount: logs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _TerminalLogEntry(message: logs[index]);
      },
    );
  }
}

class _MyLogsList extends StatelessWidget {
  final List<UserLogEvent> logs;
  final String? error;
  final String? warning;
  final String emptyLabel;

  const _MyLogsList({
    required this.logs,
    required this.error,
    required this.warning,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.warning_amber, color: AppColors.neonRed, size: 28),
          const SizedBox(height: 12),
          Text(
            error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.neonRed,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    if (logs.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (warning != null) ...[
            _MyLogsWarning(warning: warning!),
            const SizedBox(height: 12),
          ],
          Center(
            child: Text(
              emptyLabel,
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontFamily: 'monospace',
                letterSpacing: 1.5,
                fontSize: 11,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      itemCount: logs.length + (warning == null ? 0 : 1),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (warning != null && index == 0) {
          return _MyLogsWarning(warning: warning!);
        }
        final offset = warning == null ? 0 : 1;
        return _MyLogTerminalEntry(message: logs[index - offset]);
      },
    );
  }
}

class _MyLogsWarning extends StatelessWidget {
  final String warning;

  const _MyLogsWarning({required this.warning});

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              warning,
              style: const TextStyle(
                color: AppColors.neonRed,
                fontFamily: 'monospace',
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalLogEntry extends StatelessWidget {
  final ChatMessage message;

  const _TerminalLogEntry({required this.message});

  String get _timeLabel {
    final ts = message.timestamp;
    if (ts == null) return '--:--';
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '[$_timeLabel]',
                style: const TextStyle(
                  color: AppColors.neonRed,
                  fontFamily: 'monospace',
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message.nickname.toUpperCase(),
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
            ],
          ),
          const SizedBox(height: 6),
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return CyberDecryptionText(
                text: message.text,
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
    );
  }
}

class _MyLogTerminalEntry extends StatelessWidget {
  final UserLogEvent message;

  const _MyLogTerminalEntry({required this.message});

  String get _timeLabel {
    final ts = message.timestamp;
    if (ts == null) return '--:--';
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool get _isReply => message.type == UserLogType.reply;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        _isReply ? const Color(0xFF8A2BE2) : const Color(0xFF39FF14);
    final icon = _isReply ? Icons.reply_rounded : Icons.radar;
    final prefix = _isReply ? '[REPLY TO SYS.MSG] ' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 13),
              const SizedBox(width: 6),
              Text(
                '[$_timeLabel]',
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
            ],
          ),
          const SizedBox(height: 6),
          BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, languageState) {
              return CyberDecryptionText(
                text: '$prefix${message.text}',
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
    );
  }
}
