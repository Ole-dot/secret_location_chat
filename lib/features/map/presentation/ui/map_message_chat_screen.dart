import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/widgets/chat_send_icon_button.dart';
import 'package:secret_location_chat/core/widgets/terminal_confirm_dialog.dart';
import 'package:secret_location_chat/data/models/map_thread_message.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_message_chat_cubit.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class MapMessageChatScreen extends StatefulWidget {
  const MapMessageChatScreen({super.key});

  @override
  State<MapMessageChatScreen> createState() => _MapMessageChatScreenState();
}

class _MapMessageChatScreenState extends State<MapMessageChatScreen> {
  final _messageCtrl = TextEditingController();
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showTerminalConfirmDialog(
      context,
      title: 'TERMINATE SIGNAL?',
      message:
          'УНИЧТОЖИТЬ СИГНАЛ И ВСЮ ПЕРЕПИСКУ? ДАННЫЕ БУДУТ СТЁРТЫ БЕЗ ВОЗВРАТА.',
      confirmLabel: 'СЖЕЧЬ',
    );
    if (!confirmed || !context.mounted) return;

    final deleted = await context.read<MapMessageChatCubit>().deleteThread();
    if (!context.mounted || !deleted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<MapMessageChatCubit, MapMessageChatState>(
      listenWhen: (prev, next) =>
          prev.threadExpired != next.threadExpired ||
          prev.error != next.error,
      listener: (context, state) {
        if (state.threadExpired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceCard,
              content: const Text(
                'THREAD BURNED — SIGNAL EXPIRED',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          );
          context.pop();
        }
        if (state.error != null) {
          CyberSnackBar.showError(
            context,
            state.error!,
            backgroundColor: AppColors.surfaceCard,
          );
        }
      },
      builder: (context, state) {
        final remaining =
            state.parentMessage.expiresAt.difference(DateTime.now());
        final snippet = state.parentMessage.text.length > 64
            ? '${state.parentMessage.text.substring(0, 64)}...'
            : state.parentMessage.text;
        final cubit = context.read<MapMessageChatCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snippet.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '⏱ ${_formatRemaining(remaining, l10n)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: remaining.inMinutes < 5
                        ? Colors.orange
                        : AppColors.textSecondary,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (cubit.isParentAuthor)
                IconButton(
                  onPressed:
                      state.isDeleting ? null : () => _confirmDelete(context),
                  icon: state.isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.neonRed,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.local_fire_department,
                          color: AppColors.neonRed,
                        ),
                  tooltip: 'Burn thread',
                ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.borderRed),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORIGINAL SIGNAL // ${state.parentMessage.authorName.toUpperCase()}',
                      style: const TextStyle(
                        color: AppColors.neonRed,
                        fontFamily: 'monospace',
                        fontSize: 9,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.parentMessage.text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: state.parentMessage.ttlProgress,
                      minHeight: 2,
                      backgroundColor: AppColors.border,
                      color: state.parentMessage.ttlProgress > 0.3
                          ? AppColors.neonRed
                          : Colors.orange,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.neonRed,
                          strokeWidth: 2,
                        ),
                      )
                    : state.messages.isEmpty
                        ? const Center(
                            child: Text(
                              'THREAD OPEN — NO REPLIES YET',
                              style: TextStyle(
                                color: AppColors.textDisabled,
                                fontFamily: 'monospace',
                                letterSpacing: 1.4,
                                fontSize: 11,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              final isMine =
                                  message.authorUid == cubit.currentUserId;
                              return _ThreadBubble(
                                message: message,
                                isMine: isMine,
                              );
                            },
                          ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageCtrl,
                        enabled: !state.threadExpired && !state.isSending,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Transmit reply...',
                          hintStyle: TextStyle(color: AppColors.textDisabled),
                        ),
                        onSubmitted: (_) => _send(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChatSendIconButton(
                      isLoading: state.isSending,
                      onPressed: state.threadExpired || state.isSending
                          ? null
                          : () => _send(context),
                    ),
                  ],
                ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _send(BuildContext context) {
    final text = _messageCtrl.text;
    if (text.trim().isEmpty) return;
    context.read<MapMessageChatCubit>().sendMessage(text);
    _messageCtrl.clear();
  }

  String _formatRemaining(Duration d, AppLocalizations l10n) {
    if (d.isNegative) return l10n.durationSeconds(0);
    if (d.inHours > 0) {
      return l10n.durationHoursMinutes(
        d.inHours,
        d.inMinutes.remainder(60),
      );
    }
    if (d.inMinutes > 0) return l10n.durationMinutes(d.inMinutes);
    return l10n.durationSeconds(d.inSeconds);
  }
}

class _ThreadBubble extends StatelessWidget {
  final MapThreadMessage message;
  final bool isMine;

  const _ThreadBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMine ? AppColors.neonRed : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            message.authorName.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 9,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border.all(
                color: isMine ? AppColors.borderRed : AppColors.border,
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: color,
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
