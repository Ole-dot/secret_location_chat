import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/slc_button.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_bloc.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class SendMessageSheet extends StatefulWidget {
  const SendMessageSheet({super.key});

  @override
  State<SendMessageSheet> createState() => _SendMessageSheetState();
}

class _SendMessageSheetState extends State<SendMessageSheet> {
  final _ctrl = TextEditingController();
  bool _isAnon = false;
  int _ttlMinutes = 60;

  final List<int> _ttlOptions = [10, 30, 60, 180, 720, 1440];

  String _ttlLabel(int minutes, AppLocalizations l10n) =>
      minutes < 60 ? '$minutes ${l10n.unitMin}' : '${minutes ~/ 60} ${l10n.unitHour}';

  @override
  void initState() {
    super.initState();
    _isAnon = context.read<MapBloc>().state.isAnonymous;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isPremium = context.read<MapBloc>().state.isPremium;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: AppColors.borderRed, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Заголовок
          Row(
            children: [
              Text(
                l10n.sendMessageTitle,
                style: const TextStyle(
                  color: AppColors.neonRed,
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // Анонимность
              GestureDetector(
                onTap: isPremium
                    ? () => setState(() => _isAnon = !_isAnon)
                    : () => _showPremiumHint(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isAnon ? AppColors.neonRed.withValues(alpha: 0.15) : AppColors.surfaceCard,
                    border: Border.all(
                      color: _isAnon ? AppColors.neonRed : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isAnon ? '◉' : '○',
                        style: TextStyle(
                          color: _isAnon ? AppColors.neonRed : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isAnon ? l10n.modeAnon : l10n.modeOpen,
                        style: TextStyle(
                          color: _isAnon ? AppColors.neonRed : AppColors.textSecondary,
                          fontSize: 10,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isPremium) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.lock, size: 10, color: AppColors.textDisabled),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Текстовое поле
          TextField(
            controller: _ctrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            maxLines: 3,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.sendMessageHint,
              hintStyle: const TextStyle(color: AppColors.textDisabled),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // TTL выбор
          Text(
            l10n.sendMessageTtl,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: List.generate(_ttlOptions.length, (i) {
              final isSelected = _ttlMinutes == _ttlOptions[i];
              final needsPremium = i > 1 && !isPremium;
              return GestureDetector(
                onTap: needsPremium
                    ? () => _showPremiumHint(context)
                    : () => setState(() => _ttlMinutes = _ttlOptions[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.neonRed : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isSelected ? AppColors.neonRed : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _ttlLabel(_ttlOptions[i], l10n),
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (needsPremium) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.lock, size: 10, color: AppColors.textDisabled),
                      ]
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          SlcButton(
            text: _isAnon ? l10n.sendAnonymously : l10n.commonSend,
            onTap: () {
              final text = _ctrl.text.trim();
              if (text.isEmpty) return;
              context.read<MapBloc>().add(
                MapSendMessageEvent(
                  text: text,
                  isAnonymous: _isAnon,
                  ttl: Duration(minutes: _ttlMinutes),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showPremiumHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceCard,
        content: Text(
          AppLocalizations.of(context).sendPremiumHint,
          style: const TextStyle(color: AppColors.neonRed),
        ),
      ),
    );
  }
}
