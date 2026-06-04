import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/stones/stones_product_ids.dart';
import 'package:secret_location_chat/data/stones/stones_repository.dart';

class StonesState {
  final int balance;
  final List<ProductDetails> products;
  final bool isLoading;
  final bool isPurchasing;
  final bool storeAvailable;
  final String? error;
  final String? purchasingProductId;

  const StonesState({
    this.balance = 0,
    this.products = const [],
    this.isLoading = false,
    this.isPurchasing = false,
    this.storeAvailable = false,
    this.error,
    this.purchasingProductId,
  });

  StonesState copyWith({
    int? balance,
    List<ProductDetails>? products,
    bool? isLoading,
    bool? isPurchasing,
    bool? storeAvailable,
    String? error,
    String? purchasingProductId,
    bool clearError = false,
    bool clearPurchasingProductId = false,
  }) =>
      StonesState(
        balance: balance ?? this.balance,
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
        isPurchasing: isPurchasing ?? this.isPurchasing,
        storeAvailable: storeAvailable ?? this.storeAvailable,
        error: clearError ? null : (error ?? this.error),
        purchasingProductId: clearPurchasingProductId
            ? null
            : (purchasingProductId ?? this.purchasingProductId),
      );
}

class StonesCubit extends Cubit<StonesState> {
  final StonesRepository _repository;
  final InAppPurchase _iap;
  final String userId;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  StreamSubscription<int>? _balanceSub;
  bool _storeInitialized = false;

  StonesCubit({
    required this.userId,
    required StonesRepository repository,
    InAppPurchase? iap,
    bool enableStore = true,
  })  : _repository = repository,
        _iap = iap ?? InAppPurchase.instance,
        super(StonesState(isLoading: enableStore)) {
    _init(enableStore: enableStore);
  }

  StonesCubit.balanceOnly({
    required this.userId,
    required StonesRepository repository,
  })  : _repository = repository,
        _iap = InAppPurchase.instance,
        super(const StonesState(isLoading: true)) {
    _init(enableStore: false);
  }

  Future<void> _init({required bool enableStore}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid != userId) {
      emit(state.copyWith(isLoading: false, error: 'ПОЛЬЗОВАТЕЛЬ НЕ АВТОРИЗОВАН'));
      return;
    }

    try {
      await _repository.ensureStonesFields(uid);
    } catch (_) {}

    _balanceSub = _repository.watchStonesBalance(uid).listen(
      (balance) {
        if (!isClosed) {
          emit(state.copyWith(balance: balance, isLoading: false));
        }
      },
      onError: (_) {},
    );

    try {
      final balance = await _repository.fetchStonesBalance(uid);
      emit(state.copyWith(balance: balance, isLoading: false));
    } catch (err) {
      emit(state.copyWith(
        isLoading: false,
        error: mapFirebaseError(err),
      ));
    }

    if (enableStore) {
      await _ensureStoreInitialized();
    }
  }

  Future<void> _ensureStoreInitialized() async {
    if (_storeInitialized) return;
    _storeInitialized = true;

    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object err) {
        if (!isClosed) {
          emit(state.copyWith(
            isPurchasing: false,
            clearPurchasingProductId: true,
            error: mapFirebaseError(err),
          ));
        }
      },
    );

    await loadStore();
  }

  Future<bool> addStones(int amount) async {
    if (amount <= 0) return false;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid != userId) {
      emit(state.copyWith(error: 'ПОЛЬЗОВАТЕЛЬ НЕ АВТОРИЗОВАН'));
      return false;
    }

    final optimisticBalance = state.balance + amount;
    emit(state.copyWith(balance: optimisticBalance, clearError: true));

    try {
      final balanceAfter = await _repository.addStones(
        userId: uid,
        amount: amount,
      );
      emit(state.copyWith(balance: balanceAfter, clearError: true));
      return true;
    } catch (err) {
      try {
        final balance = await _repository.fetchStonesBalance(uid);
        emit(state.copyWith(
          balance: balance,
          error: mapFirebaseError(err),
        ));
      } catch (_) {
        emit(state.copyWith(error: mapFirebaseError(err)));
      }
      return false;
    }
  }

  Future<void> loadStore() async {
    await _ensureStoreInitialized();
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final available = await _iap.isAvailable();
      if (!available) {
        emit(state.copyWith(
          isLoading: false,
          storeAvailable: false,
          error: 'МАГАЗИН НЕДОСТУПЕН',
        ));
        return;
      }

      final response = await _iap.queryProductDetails(kStonesProductIds.toSet());
      final products = response.productDetails.toList()
        ..sort((a, b) {
          final amountA = stonesAmountForProduct(a.id);
          final amountB = stonesAmountForProduct(b.id);
          return amountA.compareTo(amountB);
        });

      emit(state.copyWith(
        isLoading: false,
        storeAvailable: true,
        products: products,
        clearError: true,
      ));
    } catch (err) {
      emit(state.copyWith(
        isLoading: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  Future<void> purchase(ProductDetails product) async {
    if (state.isPurchasing) return;

    emit(state.copyWith(
      isPurchasing: true,
      purchasingProductId: product.id,
      clearError: true,
    ));

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (err) {
      emit(state.copyWith(
        isPurchasing: false,
        clearPurchasingProductId: true,
        error: mapFirebaseError(err),
      ));
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        emit(state.copyWith(
          isPurchasing: false,
          clearPurchasingProductId: true,
          error: purchase.error?.message ?? 'ОШИБКА ПОКУПКИ',
        ));
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        emit(state.copyWith(
          isPurchasing: false,
          clearPurchasingProductId: true,
        ));
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        try {
          await _fulfillPurchase(purchase);
        } catch (err) {
          emit(state.copyWith(
            isPurchasing: false,
            clearPurchasingProductId: true,
            error: _mapPurchaseError(err),
          ));
        } finally {
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
        }
      }
    }
  }

  Future<void> _fulfillPurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    final amount = stonesAmountForProduct(productId);
    if (amount <= 0) {
      throw StateError('UNKNOWN_PRODUCT');
    }

    final token = purchase.verificationData.serverVerificationData.isNotEmpty
        ? purchase.verificationData.serverVerificationData
        : purchase.purchaseID ?? purchase.productID;

    final orderId = purchase.purchaseID ?? token;
    final idempotencyKey = 'iap_${userId}_$orderId';

    final balanceAfter = await _repository.creditFromPurchase(
      userId: userId,
      amount: amount,
      productId: productId,
      storePlatform: _storePlatform(),
      purchaseToken: token,
      orderId: orderId,
      idempotencyKey: idempotencyKey,
    );

    emit(state.copyWith(
      balance: balanceAfter,
      isPurchasing: false,
      clearPurchasingProductId: true,
      clearError: true,
    ));
  }

  String _storePlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'app_store';
    if (defaultTargetPlatform == TargetPlatform.android) return 'google_play';
    return 'unknown';
  }

  String _mapPurchaseError(Object err) {
    if (err is StateError) {
      return switch (err.message) {
        'USER_NOT_FOUND' => 'ПРОФИЛЬ НЕ НАЙДЕН',
        'INVALID_STONES_AMOUNT' => 'НЕВЕРНАЯ СУММА',
        _ => mapFirebaseError(err),
      };
    }
    return mapFirebaseError(err);
  }

  @override
  Future<void> close() {
    _purchaseSub?.cancel();
    _balanceSub?.cancel();
    return super.close();
  }
}
