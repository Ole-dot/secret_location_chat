import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/data/prefs/user_prefs_service.dart';
import 'package:secret_location_chat/features/map/presentation/bloc/map_bloc.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

/// Показывается, если на /plan перешли без [MapBloc] в [GoRouterState.extra].
class PlanScreenMissingBloc extends StatelessWidget {
  const PlanScreenMissingBloc({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.planTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.planMissingHint,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/map'),
                child: Text(l10n.planToMap, style: const TextStyle(color: AppColors.neonRed)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPlan = context.select((MapBloc b) => b.state.plan);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.planTitle),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 18),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с тестовой пометкой
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neonRed.withValues(alpha: 0.08),
                border: Border.all(color: AppColors.borderRed),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined, color: AppColors.neonRed, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.planTestModeBanner,
                      style: const TextStyle(color: AppColors.neonRed, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _PlanCard(
                    plan: UserPlan.free,
                    currentPlan: currentPlan,
                    price: '₸ 0',
                    subtitle: l10n.planFreeSubtitle,
                    color: AppColors.textSecondary,
                    features: [
                      _Feature((l) => l.planFeatMsg5PerDay, true),
                      _Feature((l) => l.planFeatTtl1h, true),
                      _Feature((l) => l.planFeatStandardNick, true),
                      _Feature((l) => l.planFeatAnonMode, false),
                      _Feature((l) => l.planFeatTtl24h, false),
                      _Feature((l) => l.planFeatAvatarsGifts, false),
                      _Feature((l) => l.planFeatTotemCompass, false),
                      _Feature((l) => l.planFeatUnityGame, false),
                      _Feature((l) => l.planFeatPrivateZones, false),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _PlanCard(
                    plan: UserPlan.premium,
                    currentPlan: currentPlan,
                    price: '₸ 5 000${l10n.perMonth}',
                    subtitle: l10n.planPremiumSubtitle,
                    color: AppColors.neonRed,
                    isFeatured: true,
                    features: [
                      _Feature((l) => l.planFeatUnlimitedMsg, true),
                      _Feature((l) => l.planFeatTtl24h, true),
                      _Feature((l) => l.planFeatAnonShadow, true),
                      _Feature((l) => l.planFeatCustomAvatars, true),
                      _Feature((l) => l.planFeatGiftsToUsers, true),
                      _Feature((l) => l.planFeatTotemCompass, true),
                      _Feature((l) => l.planFeatUnityGame, true),
                      _Feature((l) => l.planFeatPrivateZones, false),
                      _Feature((l) => l.planFeatApiIntegrations, false),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _PlanCard(
                    plan: UserPlan.enterprise,
                    currentPlan: currentPlan,
                    price: '₸ 50 000+${l10n.perMonth}',
                    subtitle: l10n.planEnterpriseSubtitle,
                    color: const Color(0xFF7F77DD),
                    features: [
                      _Feature((l) => l.planFeatAllPremium, true),
                      _Feature((l) => l.planFeatPrivateGeozones, true),
                      _Feature((l) => l.planFeatTeamChats, true),
                      _Feature((l) => l.planFeatActivityAnalytics, true),
                      _Feature((l) => l.planFeatApiIntegrations, true),
                      _Feature((l) => l.planFeatWhiteLabel, true),
                      _Feature((l) => l.planFeatPrioritySupport, true),
                      _Feature((l) => l.planFeatE2eEncryption, true),
                      _Feature((l) => l.planFeatSlaGuarantees, true),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature {
  final String Function(AppLocalizations) text;
  final bool included;
  const _Feature(this.text, this.included);
}

class _PlanCard extends StatelessWidget {
  final UserPlan plan;
  final UserPlan currentPlan;
  final String price;
  final String subtitle;
  final Color color;
  final bool isFeatured;
  final List<_Feature> features;

  const _PlanCard({
    required this.plan,
    required this.currentPlan,
    required this.price,
    required this.subtitle,
    required this.color,
    required this.features,
    this.isFeatured = false,
  });

  bool get isActive => plan == currentPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color : AppColors.border,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 16, spreadRadius: 0)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок карточки
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.label.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                          if (isFeatured) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.neonRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.neonRed.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                l10n.planBadgeHit,
                                style: const TextStyle(color: AppColors.neonRed, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 6),
                      Text(
                        price,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // Активный бейдж / кнопка выбрать
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Text(l10n.planBadgeActive, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  )
                else
                  GestureDetector(
                    onTap: () => _selectPlan(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withValues(alpha: 0.5)),
                      ),
                      child: Text(l10n.planSelect, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    ),
                  ),
              ],
            ),
          ),

          // Список фич
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      f.included ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                      size: 16,
                      color: f.included ? color : AppColors.textDisabled,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      f.text(l10n),
                      style: TextStyle(
                        color: f.included ? AppColors.textPrimary : AppColors.textDisabled,
                        fontSize: 13,
                        decoration: f.included ? null : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),

          // Кнопка активировать внизу (крупная)
          if (!isActive)
            GestureDetector(
              onTap: () => _selectPlan(context),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.planActivate(plan.label),
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _selectPlan(BuildContext context) {
    context.read<MapBloc>().add(MapPlanChangedEvent(plan));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceCard,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: color, size: 18),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context).planActivatedSnack(plan.label),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ],
        ),
      ),
    );

    // Небольшая задержка, чтобы пользователь увидел snackbar, затем назад
    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) context.pop();
    });
  }
}
