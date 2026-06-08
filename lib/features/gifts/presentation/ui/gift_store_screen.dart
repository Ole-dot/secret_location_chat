import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:secret_location_chat/core/localization/l10n_error.dart';
import 'package:secret_location_chat/core/theme/app_colors.dart';
import 'package:secret_location_chat/core/widgets/cyberpunk_button.dart';
import 'package:secret_location_chat/data/models/gift_catalog_item.dart';
import 'package:secret_location_chat/data/models/inventory_item.dart';
import 'package:secret_location_chat/features/gifts/gift_store_launch_args.dart';
import 'package:secret_location_chat/features/gifts/presentation/bloc/gift_store_cubit.dart';
import 'package:secret_location_chat/features/stones/presentation/bloc/stones_cubit.dart';
import 'package:secret_location_chat/features/stones/presentation/ui/stones_balance_chip.dart';
import 'package:secret_location_chat/l10n/app_localizations.dart';

const _localGiftCatalog = <GiftCatalogItem>[
  GiftCatalogItem(
    giftId: 'glitch_dust',
    name: 'GLITCH DUST',
    stoneCost: 5,
    assetKey: 'assets/images/gifts/kolba.png',
    tier: 'common',
  ),
  GiftCatalogItem(
    giftId: 'stimpack',
    name: 'STIMPACK',
    stoneCost: 10,
    assetKey: 'assets/images/gifts/shpriz.png',
    tier: 'common',
  ),
  GiftCatalogItem(
    giftId: 'data_drive',
    name: 'DATA DRIVE',
    stoneCost: 15,
    assetKey: 'assets/images/gifts/fleska.png',
    tier: 'common',
  ),
  GiftCatalogItem(
    giftId: 'neon_rose',
    name: 'NEON ROSE',
    stoneCost: 20,
    assetKey: 'assets/images/gifts/rosa.png',
    tier: 'common',
  ),
  GiftCatalogItem(
    giftId: 'cyber_cube',
    name: 'CYBER CUBE',
    stoneCost: 30,
    assetKey: 'assets/images/gifts/kvadrat.png',
    tier: 'common',
  ),
  GiftCatalogItem(
    giftId: 'plasma_sphere',
    name: 'PLASMA SPHERE',
    stoneCost: 40,
    assetKey: 'assets/images/gifts/shar.png',
    tier: 'rare',
  ),
  GiftCatalogItem(
    giftId: 'holo_dog',
    name: 'HOLO DOG',
    stoneCost: 50,
    assetKey: 'assets/images/gifts/cobaka.png',
    tier: 'rare',
  ),
  GiftCatalogItem(
    giftId: 'cyber_cat',
    name: 'CYBER CAT',
    stoneCost: 60,
    assetKey: 'assets/images/gifts/kissa.png',
    tier: 'rare',
  ),
  GiftCatalogItem(
    giftId: 'power_glove',
    name: 'POWER GLOVE',
    stoneCost: 80,
    assetKey: 'assets/images/gifts/perhatka.png',
    tier: 'rare',
  ),
  GiftCatalogItem(
    giftId: 'encrypted_scroll',
    name: 'ENCRYPTED SCROLL',
    stoneCost: 100,
    assetKey: 'assets/images/gifts/svitok.png',
    tier: 'legendary',
  ),
  GiftCatalogItem(
    giftId: 'bionic_eye',
    name: 'BIONIC EYE',
    stoneCost: 250,
    assetKey: 'assets/images/gifts/glaz.png',
    tier: 'legendary',
  ),
  GiftCatalogItem(
    giftId: 'holo_knife',
    name: 'HOLO KNIFE',
    stoneCost: 500,
    assetKey: 'assets/images/gifts/nozh.png',
    tier: 'legendary',
  ),
  GiftCatalogItem(
    giftId: 'black_ice_brain',
    name: 'BLACK ICE BRAIN',
    stoneCost: 1000,
    assetKey: 'assets/images/gifts/mazg.png',
    tier: 'legendary',
  ),
];

class GiftStoreScreen extends StatelessWidget {
  final GiftStoreLaunchArgs args;

  const GiftStoreScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text(
            'GIFT SHOWCASE',
            style: TextStyle(
              fontFamily: 'monospace',
              letterSpacing: 3,
              fontWeight: FontWeight.w900,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => context.pop(),
          ),
          actions: [
            BlocBuilder<StonesCubit, StonesState>(
              builder: (context, stonesState) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: StonesBalanceChip(balance: stonesState.balance),
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderRed),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.neonRed.withValues(alpha: 0.16),
                  border: const Border(
                    bottom: BorderSide(color: AppColors.neonRed, width: 2),
                  ),
                ),
                labelColor: AppColors.neonRed,
                unselectedLabelColor: AppColors.textSecondary,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  fontSize: 11,
                ),
                tabs: const [
                  Tab(text: 'STORE'),
                  Tab(text: 'MY STASH'),
                ],
              ),
            ),
          ),
        ),
        body: BlocConsumer<GiftStoreCubit, GiftStoreState>(
          listenWhen: (prev, next) =>
              prev.successMessage != next.successMessage ||
              prev.error != next.error,
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.surfaceCard,
                  content: Text(
                    l10nByKey(
                      AppLocalizations.of(context),
                      state.successMessage!,
                    ),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final balance = context.select((StonesCubit c) => c.state.balance);
            final gifts = List<GiftCatalogItem>.from(
              state.catalog.isNotEmpty ? state.catalog : _localGiftCatalog,
            )..sort((a, b) => a.stoneCost.compareTo(b.stoneCost));

            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.neonRed),
              );
            }

            return TabBarView(
              children: [
                _StoreTab(
                  gifts: gifts,
                  balance: balance,
                  state: state,
                ),
                _StashTab(items: state.inventory),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StoreTab extends StatelessWidget {
  final List<GiftCatalogItem> gifts;
  final int balance;
  final GiftStoreState state;

  const _StoreTab({
    required this.gifts,
    required this.balance,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            border: Border.all(color: AppColors.borderRed),
          ),
          child: const Text(
            'TERMINAL:// SELECT GIFT · TAP BUY',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              letterSpacing: 1.3,
              fontSize: 11,
            ),
          ),
        ),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10nByKey(AppLocalizations.of(context), state.error!),
              style: const TextStyle(
                color: AppColors.neonRed,
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.76,
            ),
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = gifts[index];
              return _AnimatedGiftCard(
                gift: gift,
                canAfford: balance >= gift.stoneCost,
                isBuying: state.isBuying && state.buyingGiftId == gift.giftId,
                onBuy: () => context.read<GiftStoreCubit>().buyGiftPreview(
                      gift: gift,
                      currentBalance: balance,
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StashTab extends StatelessWidget {
  final List<InventoryItem> items;

  const _StashTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'NO ITEMS IN STASH. ACQUIRE ASSETS IN STORE.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'monospace',
            letterSpacing: 1.2,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.86,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _StashItemCard(item: items[index]),
    );
  }
}

class _AnimatedGiftCard extends StatefulWidget {
  final GiftCatalogItem gift;
  final bool canAfford;
  final bool isBuying;
  final VoidCallback onBuy;

  const _AnimatedGiftCard({
    required this.gift,
    required this.canAfford,
    required this.isBuying,
    required this.onBuy,
  });

  @override
  State<_AnimatedGiftCard> createState() => _AnimatedGiftCardState();
}

class _AnimatedGiftCardState extends State<_AnimatedGiftCard>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _glitchController;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _glitchX;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat(reverse: true);

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _iconScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _iconOpacity = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _glitchX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: -2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2, end: 0), weight: 1),
    ]).animate(_glitchController);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  void _triggerGlitch() {
    _glitchController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final affordColor = widget.canAfford ? AppColors.neonRed : AppColors.textDisabled;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathController, _glitchController]),
        builder: (context, _) {
          final glitching = _glitchController.isAnimating || widget.isBuying;
          final shiftY = glitching
              ? math.sin(_glitchController.value * math.pi * 6) * 1.3
              : 0;
          final rotate = glitching
              ? math.sin(_glitchController.value * math.pi * 4) * 0.014
              : 0;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(_glitchX.value, shiftY.toDouble())
              ..rotateZ(rotate.toDouble()),
            child: ColorFiltered(
              colorFilter: glitching
                  ? const ColorFilter.mode(Colors.white24, BlendMode.screen)
                  : const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
              child: GestureDetector(
                onTap: _triggerGlitch,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    border: Border.all(color: AppColors.borderRed, width: 1.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Center(
                          child: Opacity(
                            opacity: _iconOpacity.value,
                            child: Transform.scale(
                              scale: _iconScale.value,
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  border: Border.all(color: AppColors.borderRed),
                                ),
                                child: Image.asset(
                                  widget.gift.assetKey,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        widget.gift.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.diamond, color: affordColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.gift.stoneCost} STONES',
                            style: TextStyle(
                              color: affordColor,
                              fontFamily: 'monospace',
                              fontSize: 10,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CyberpunkButton(
                        text: 'BUY',
                        height: 34,
                        isLoading: widget.isBuying,
                        onPressed: widget.canAfford
                            ? () {
                                _triggerGlitch();
                                widget.onBuy();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StashItemCard extends StatefulWidget {
  final InventoryItem item;

  const _StashItemCard({required this.item});

  @override
  State<_StashItemCard> createState() => _StashItemCardState();
}

class _StashItemCardState extends State<_StashItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathController;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat(reverse: true);
    _iconScale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _iconOpacity = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  void _openTransferDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.borderRed),
        ),
        title: const Text(
          'SELECT TARGET TO INITIATE TRANSFER PROTOCOL',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'monospace',
            fontSize: 12,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'SEND',
              style: TextStyle(
                color: AppColors.neonRed,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openTransferDialog,
      child: AnimatedBuilder(
        animation: _breathController,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border.all(color: AppColors.borderRed, width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: Opacity(
                      opacity: _iconOpacity.value,
                      child: Transform.scale(
                        scale: _iconScale.value,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            border: Border.all(color: AppColors.borderRed),
                          ),
                          child: Image.asset(
                            widget.item.assetPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  widget.item.giftName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'TAP TO TRANSFER',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 1.1,
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
