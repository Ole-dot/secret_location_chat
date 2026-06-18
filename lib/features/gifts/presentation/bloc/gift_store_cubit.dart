import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/gifts/gift_repository.dart';
import 'package:secret_location_chat/data/models/gift_catalog_item.dart';
import 'package:secret_location_chat/data/models/inventory_item.dart';

class GiftStoreState {
  final List<GiftCatalogItem> catalog;
  final List<InventoryItem> inventory;
  final bool isLoading;
  final bool isSending;
  final bool isBuying;
  final String? sendingGiftId;
  final String? buyingGiftId;
  final String? successMessage;
  final String? error;

  const GiftStoreState({
    this.catalog = const [],
    this.inventory = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isBuying = false,
    this.sendingGiftId,
    this.buyingGiftId,
    this.successMessage,
    this.error,
  });

  GiftStoreState copyWith({
    List<GiftCatalogItem>? catalog,
    List<InventoryItem>? inventory,
    bool? isLoading,
    bool? isSending,
    bool? isBuying,
    String? sendingGiftId,
    String? buyingGiftId,
    String? successMessage,
    String? error,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSendingGiftId = false,
    bool clearBuyingGiftId = false,
  }) =>
      GiftStoreState(
        catalog: catalog ?? this.catalog,
        inventory: inventory ?? this.inventory,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        isBuying: isBuying ?? this.isBuying,
        sendingGiftId: clearSendingGiftId
            ? null
            : (sendingGiftId ?? this.sendingGiftId),
        buyingGiftId: clearBuyingGiftId
            ? null
            : (buyingGiftId ?? this.buyingGiftId),
        successMessage:
            clearSuccess ? null : (successMessage ?? this.successMessage),
        error: clearError ? null : (error ?? this.error),
      );
}

class GiftStoreCubit extends Cubit<GiftStoreState> {
  final GiftRepository _giftRepository;
  final String userId;
  final String nickname;
  final String avatar;
  StreamSubscription<List<InventoryItem>>? _inventorySub;

  GiftStoreCubit({
    required this.userId,
    required this.nickname,
    required this.avatar,
    required GiftRepository giftRepository,
  })  : _giftRepository = giftRepository,
        super(const GiftStoreState(isLoading: true)) {
    _watchInventory();
    load();
  }

  void _watchInventory() {
    _inventorySub?.cancel();
    _inventorySub = _giftRepository.watchInventory(userId).listen(
      (items) {
        if (isClosed) return;
        emit(state.copyWith(inventory: items));
      },
      onError: (err, stackTrace) {
        logPurchaseError('GiftStoreCubit.watchInventory', err, stackTrace);
        if (isClosed) return;
        emit(state.copyWith(error: formatErrorForDisplay(err)));
      },
    );
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      final catalog = await _giftRepository.fetchCatalog();
      emit(state.copyWith(
        isLoading: false,
        catalog: catalog,
        clearError: true,
      ));
    } catch (err) {
      emit(state.copyWith(
        isLoading: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  Future<void> sendGift({
    required GiftCatalogItem gift,
    required String recipientUserId,
    required int currentBalance,
    String message = '',
  }) async {
    if (state.isSending) return;
    if (currentBalance < gift.stoneCost) {
      emit(state.copyWith(error: 'НЕДОСТАТОЧНО СТОУНОВ'));
      return;
    }

    emit(state.copyWith(
      isSending: true,
      sendingGiftId: gift.giftId,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      await _giftRepository.sendGift(
        senderUserId: userId,
        senderNickname: nickname,
        senderAvatar: avatar,
        recipientUserId: recipientUserId,
        gift: gift,
        message: message,
      );

      emit(state.copyWith(
        isSending: false,
        clearSendingGiftId: true,
        successMessage: 'giftSent',
        clearError: true,
      ));
    } catch (err) {
      emit(state.copyWith(
        isSending: false,
        clearSendingGiftId: true,
        error: _mapGiftError(err),
      ));
    }
  }

  String _mapGiftError(Object err) {
    if (err is StateError) {
      return switch (err.message) {
        'INSUFFICIENT_STONES' => 'НЕДОСТАТОЧНО СТОУНОВ',
        'CANNOT_GIFT_SELF' => 'НЕЛЬЗЯ ОТПРАВИТЬ СЕБЕ',
        'USER_NOT_FOUND' => 'ПОЛЬЗОВАТЕЛЬ НЕ НАЙДЕН',
        _ => mapFirebaseError(err),
      };
    }
    return mapFirebaseError(err);
  }

  Future<void> buyGiftPreview({
    required GiftCatalogItem gift,
    required int currentBalance,
  }) async {
    debugPrint(
      '[GiftStoreCubit] buyGiftPreview triggered '
      'giftId=${gift.giftId} stoneCost=${gift.stoneCost} '
      'currentBalance=$currentBalance userId=$userId',
    );

    if (state.isBuying || state.isSending) {
      debugPrint('[GiftStoreCubit] buyGiftPreview aborted: busy');
      return;
    }

    final cost = gift.stoneCost;
    if (cost <= 0) {
      final message =
          'Некорректная цена гифта (${gift.giftId}: stoneCost=$cost)';
      debugPrint('[GiftStoreCubit] buyGiftPreview aborted: $message');
      emit(state.copyWith(error: message));
      return;
    }

    if (currentBalance < cost) {
      debugPrint(
        '[GiftStoreCubit] buyGiftPreview aborted: insufficient stones '
        '(balance=$currentBalance, cost=$cost)',
      );
      emit(state.copyWith(error: 'НЕДОСТАТОЧНО СТОУНОВ'));
      return;
    }

    emit(state.copyWith(
      isBuying: true,
      buyingGiftId: gift.giftId,
      clearError: true,
      clearSuccess: true,
    ));

    try {
      await _giftRepository.buyToInventory(
        userId: userId,
        gift: gift,
      );
      debugPrint('[GiftStoreCubit] buyGiftPreview success giftId=${gift.giftId}');
      emit(state.copyWith(
        isBuying: false,
        clearBuyingGiftId: true,
        successMessage: 'АЙТЕМ СЕНТ ТУ МАЙ СТЭШ',
        clearError: true,
      ));
    } catch (err, stackTrace) {
      logPurchaseError('GiftStoreCubit.buyGiftPreview', err, stackTrace);
      emit(state.copyWith(
        isBuying: false,
        clearBuyingGiftId: true,
        error: formatErrorForDisplay(err),
      ));
    }
  }

  @override
  Future<void> close() {
    _inventorySub?.cancel();
    return super.close();
  }
}
