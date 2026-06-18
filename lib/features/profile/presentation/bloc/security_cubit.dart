import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';

enum SelfDestructResult { success, requiresRecentLogin, failed }

class SecurityState {
  final bool isSendingReset;
  final bool isDeleting;
  final String? successMessage;
  final String? error;

  const SecurityState({
    this.isSendingReset = false,
    this.isDeleting = false,
    this.successMessage,
    this.error,
  });

  SecurityState copyWith({
    bool? isSendingReset,
    bool? isDeleting,
    String? successMessage,
    String? error,
    bool clearSuccess = false,
    bool clearError = false,
  }) =>
      SecurityState(
        isSendingReset: isSendingReset ?? this.isSendingReset,
        isDeleting: isDeleting ?? this.isDeleting,
        successMessage:
            clearSuccess ? null : (successMessage ?? this.successMessage),
        error: clearError ? null : (error ?? this.error),
      );
}

class SecurityCubit extends Cubit<SecurityState> {
  final AuthRepository _authRepository;
  final String email;

  SecurityCubit({
    required AuthRepository authRepository,
    required this.email,
  })  : _authRepository = authRepository,
        super(const SecurityState());

  Future<void> sendPasswordReset() async {
    if (state.isSendingReset) return;
    emit(state.copyWith(
      isSendingReset: true,
      clearError: true,
      clearSuccess: true,
    ));
    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(state.copyWith(
        isSendingReset: false,
        successMessage: 'RESET LINK SENT TO EMAIL',
        clearError: true,
      ));
    } catch (err) {
      emit(state.copyWith(
        isSendingReset: false,
        error: mapFirebaseError(err),
      ));
    }
  }

  Future<SelfDestructResult> executeSelfDestruct() async {
    if (state.isDeleting) return SelfDestructResult.failed;
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) {
      emit(state.copyWith(error: 'ПОЛЬЗОВАТЕЛЬ НЕ АВТОРИЗОВАН'));
      return SelfDestructResult.failed;
    }

    emit(state.copyWith(
      isDeleting: true,
      clearError: true,
      clearSuccess: true,
    ));
    try {
      await _authRepository.deleteAccount(uid);
      emit(state.copyWith(isDeleting: false, clearError: true));
      return SelfDestructResult.success;
    } on FirebaseAuthException catch (err) {
      emit(state.copyWith(isDeleting: false, clearError: true));
      if (err.code == 'requires-recent-login') {
        return SelfDestructResult.requiresRecentLogin;
      }
      emit(state.copyWith(error: mapFirebaseError(err)));
      return SelfDestructResult.failed;
    } catch (err) {
      emit(state.copyWith(
        isDeleting: false,
        error: mapFirebaseError(err),
      ));
      return SelfDestructResult.failed;
    }
  }
}
