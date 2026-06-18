import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/chat_send_icon_button.dart';
import 'package:secret_location_chat/data/chat/global_chat_repository.dart';
import 'package:secret_location_chat/data/models/chat_message_model.dart';
import 'package:secret_location_chat/features/chat/global_chat_launch_args.dart';
import 'package:secret_location_chat/features/chat/presentation/bloc/global_chat_bloc.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class GlobalChatScreen extends StatefulWidget {
  final GlobalChatLaunchArgs args;

  const GlobalChatScreen({super.key, required this.args});

  @override
  State<GlobalChatScreen> createState() => _GlobalChatScreenState();
}

class _GlobalChatScreenState extends State<GlobalChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (_) => GlobalChatBloc(
        repo: GlobalChatRepository(),
        userId: widget.args.userId,
        nickname: widget.args.nickname,
        avatar: widget.args.avatar,
      )..add(GlobalChatStartedEvent()),
      child: BlocConsumer<GlobalChatBloc, GlobalChatState>(
        listenWhen: (prev, next) {
          if (prev is GlobalChatReadyState && next is GlobalChatReadyState) {
            return prev.messages.length != next.messages.length;
          }
          return false;
        },
        listener: (_, __) => _scrollToBottom(),
        builder: (context, state) {
          final ready = state is GlobalChatReadyState ? state : null;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(l10n.chatTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => context.pop(),
              ),
            ),
            body: Column(
              children: [
                if (widget.args.previewText != null &&
                    widget.args.previewText!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.neonRed.withValues(alpha: 0.08),
                      border: Border.all(color: AppColors.borderRed),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.chatYouTyped,
                          style: const TextStyle(
                            color: AppColors.neonRed,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.args.previewText!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ready == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.neonRed,
                          ),
                        )
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(16),
                          itemCount: ready.messages.length,
                          itemBuilder: (context, i) {
                            final msg = ready.messages[i];
                            final isMe = msg.userId == widget.args.userId;
                            return _ChatBubble(
                              message: msg,
                              isMe: isMe,
                            );
                          },
                        ),
                ),
                if (ready?.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10nByKey(l10n, ready!.error!),
                      style: const TextStyle(color: AppColors.neonRed, fontSize: 12),
                    ),
                  ),
                _InputBar(
                  controller: _input,
                  isSending: ready?.isSending ?? false,
                  onSend: () {
                    context.read<GlobalChatBloc>().add(
                      GlobalChatSendEvent(_input.text),
                    );
                    _input.clear();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.neonRed.withValues(alpha: 0.15) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isMe ? AppColors.borderRed : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    'assets/user/${message.avatar}',
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  message.nickname,
                  style: TextStyle(
                    color: isMe ? AppColors.neonRed : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (message.isPendingSync) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.schedule, size: 12, color: Colors.orange.shade300),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message.text,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.chatInputHint,
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            ChatSendIconButton(
              isLoading: isSending,
              onPressed: isSending ? null : onSend,
            ),
          ],
        ),
      ),
    );
  }
}
