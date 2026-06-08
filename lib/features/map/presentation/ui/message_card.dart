import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/localization/language_cubit.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/data/models/geo_message_model.dart';
import 'package:secret_location_chat/features/map/presentation/ui/widgets/cyber_decryption_text.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class MessageCard extends StatelessWidget {
  final GeoMessage message;
  final VoidCallback onClose;
  final VoidCallback onReply;
  final VoidCallback onOpenChat;

  const MessageCard({
    super.key,
    required this.message,
    required this.onClose,
    required this.onReply,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ttlProgress = message.ttlProgress;
    final remaining = message.expiresAt.difference(DateTime.now());
    final timeStr = _formatRemaining(remaining, l10n);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenChat,
        borderRadius: BorderRadius.circular(8),
        child: Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderRed, width: 1),
        boxShadow: [
          BoxShadow(color: AppColors.neonRedGlow, blurRadius: 16, spreadRadius: 0),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TTL progress bar
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: LinearProgressIndicator(
              value: ttlProgress,
              backgroundColor: AppColors.border,
              color: ttlProgress > 0.3 ? AppColors.neonRed : Colors.orange,
              minHeight: 2,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Аватар
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                          color: message.isAnonymous ? AppColors.neonRed : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          message.isAnonymous ? '◉' : message.authorName[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            color: message.isAnonymous ? AppColors.neonRed : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  message.authorName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (message.isPendingSync) ...[
                                const SizedBox(width: 6),
                                Tooltip(
                                  message: l10n.messagePendingSync,
                                  child: Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: Colors.orange.shade300,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            message.isPendingSync
                                ? l10n.messagePendingSyncAt(timeStr)
                                : '⏱ $timeStr',
                            style: TextStyle(
                              color: message.isPendingSync
                                  ? Colors.orange.shade300
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Текст сообщения
                BlocBuilder<LanguageCubit, LanguageState>(
                  builder: (context, languageState) {
                    return CyberDecryptionText(
                      text: message.text,
                      targetLanguageCode: languageState.languageCode,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Footer
                Row(
                  children: [
                    if (message.replyCount > 0)
                      Text(
                        l10n.messageRepliesCount(message.replyCount),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onOpenChat,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neonRed),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          l10n.messageToChat,
                          style: const TextStyle(
                            color: AppColors.neonRed,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
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

  String _formatRemaining(Duration d, AppLocalizations l10n) {
    if (d.inHours > 0) return l10n.durationHoursMinutes(d.inHours, d.inMinutes.remainder(60));
    if (d.inMinutes > 0) return l10n.durationMinutes(d.inMinutes);
    return l10n.durationSeconds(d.inSeconds);
  }
}
