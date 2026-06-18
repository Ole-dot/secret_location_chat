import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/data/stones/stones_product_ids.dart';
import 'package:secret_location_chat/features/stones/presentation/bloc/stones_cubit.dart';
import 'package:secret_location_chat/features/stones/presentation/ui/stones_balance_chip.dart';
import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

class StonesStoreScreen extends StatefulWidget {
  const StonesStoreScreen({super.key});

  @override
  State<StonesStoreScreen> createState() => _StonesStoreScreenState();
}

class _StonesStoreScreenState extends State<StonesStoreScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StonesCubit>().loadStore();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'СТОУНЫ',
          style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<StonesCubit, StonesState>(
        builder: (context, state) {
          return SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: StonesBalanceChip(balance: state.balance)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.stonesSubtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Пополните баланс Стоунов для отправки подарков в чате.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          border: Border.all(color: AppColors.neonRed, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.neonRedGlow,
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.terminal,
                                  color: AppColors.neonRed,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'TERMINAL:// SIDE QUEST',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            CyberpunkButton(
                              text: 'Заработать деньги',
                              height: 48,
                              onPressed: () => context.push('/minigame'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10nByKey(l10n, state.error!),
                      style: const TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.neonRed,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: state.products.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            return _StonesProductTile(
                              product: product,
                              isPurchasing: state.isPurchasing &&
                                  state.purchasingProductId == product.id,
                              onBuy: state.isPurchasing
                                  ? null
                                  : () => context
                                      .read<StonesCubit>()
                                      .purchase(product),
                            );
                          },
                        ),
                ),
                if (!state.storeAvailable && !state.isLoading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: CyberpunkButton(
                      text: l10n.stonesRefreshStore,
                      isOutlined: true,
                      onPressed: () =>
                          context.read<StonesCubit>().loadStore(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StonesProductTile extends StatelessWidget {
  final ProductDetails product;
  final bool isPurchasing;
  final VoidCallback? onBuy;

  const _StonesProductTile({
    required this.product,
    required this.isPurchasing,
    this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final amount = stonesAmountForProduct(product.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neonRed.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.borderRed),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.diamond,
              color: AppColors.neonRed,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$amount СТОУНЫ',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description.isNotEmpty
                      ? product.description
                      : product.title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: CyberpunkButton(
              text: product.price,
              height: 44,
              isLoading: isPurchasing,
              onPressed: onBuy,
            ),
          ),
        ],
      ),
    );
  }
}
