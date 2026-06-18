import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/ui/cyber_snackbar.dart';
import 'package:secret_location_chat/core/widgets/chat_send_icon_button.dart';
import 'package:secret_location_chat/data/models/clan_chat_message.dart';
import 'package:secret_location_chat/features/profile/presentation/bloc/clan_chat_cubit.dart';

class ClanChatScreen extends StatefulWidget {
  const ClanChatScreen({super.key});

  @override
  State<ClanChatScreen> createState() => _ClanChatScreenState();
}

class _ClanChatScreenState extends State<ClanChatScreen> {
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.neonRed),
        ),
        title: const Text(
          'УНИЧТОЖИТЬ ЧАТ',
          style: TextStyle(
            color: AppColors.neonRed,
            fontFamily: 'monospace',
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'УДАЛИТЬ ВСЕ СООБЩЕНИЯ СЕМЕЙНОГО ЧАТА ДЛЯ ВСЕХ?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'monospace',
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ОТМЕНА', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'СЖЕЧЬ',
              style: TextStyle(
                color: AppColors.neonRed,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<ClanChatCubit>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClanChatCubit, ClanChatState>(
      listenWhen: (prev, next) =>
          prev.successMessage != next.successMessage ||
          prev.error != next.error,
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceCard,
              content: Text(
                state.successMessage!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          );
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
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            title: Text(
              state.chatName.toUpperCase(),
              style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_forever, color: AppColors.neonRed),
                onPressed: state.isClearing ? null : _confirmClear,
                tooltip: 'Очистить историю',
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderRed),
                  color: AppColors.surfaceCard,
                ),
                child: const Text(
                  'ЭФЕМЕРНЫЙ КАНАЛ · СООБЩЕНИЯ ИСЧЕЗАЮТ ЧЕРЕЗ 24Ч',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
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
                              'НЕТ АКТИВНЫХ ПЕРЕДАЧ',
                              style: TextStyle(
                                color: AppColors.textDisabled,
                                fontFamily: 'monospace',
                                letterSpacing: 1.5,
                                fontSize: 11,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            reverse: true,
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final msg = state.messages[index];
                              return _ChatBubble(message: msg);
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
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Передай сообщение...',
                          hintStyle: TextStyle(color: AppColors.textDisabled),
                        ),
                        onSubmitted: (_) => _send(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChatSendIconButton(
                      isLoading: state.isSending,
                      onPressed: state.isSending ? null : () => _send(context),
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
    context.read<ClanChatCubit>().sendMessage(text);
    _messageCtrl.clear();
  }
}

class _ChatBubble extends StatelessWidget {
  final ClanChatMessage message;

  const _ChatBubble({required this.message});

  String get _timeLabel {
    final ts = message.timestamp;
    if (ts == null) return '--:--';
    return '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
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
                message.authorName.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.neonRed,
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                _timeLabel,
                style: const TextStyle(
                  color: AppColors.textDisabled,
                  fontFamily: 'monospace',
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message.text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
