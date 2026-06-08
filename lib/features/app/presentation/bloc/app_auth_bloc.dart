import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';
import 'package:secret_location_chat/data/models/user_model.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AppAuthEvent {}

class AppAuthCheckEvent extends AppAuthEvent {}

class AppAuthLoginEvent extends AppAuthEvent {
  final String email;
  final String password;
  AppAuthLoginEvent(this.email, this.password);
}

class AppAuthLogoutEvent extends AppAuthEvent {}

class AppAuthRefreshProfileEvent extends AppAuthEvent {}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AppAuthState {}

class AppAuthInitialState extends AppAuthState {}

class AppAuthLoadingState extends AppAuthState {}

class AppAuthAuthenticatedState extends AppAuthState {
  final UserModel user;
  AppAuthAuthenticatedState(this.user);
}

class AppAuthUnauthenticatedState extends AppAuthState {}

class AppAuthErrorState extends AppAuthState {
  final String message;
  AppAuthErrorState(this.message);
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AppAuthBloc extends Bloc<AppAuthEvent, AppAuthState> {
  final AuthRepository _authRepository;

  AppAuthBloc(this._authRepository) : super(AppAuthInitialState()) {
    on<AppAuthCheckEvent>(_onCheck);
    on<AppAuthLoginEvent>(_onLogin);
    on<AppAuthLogoutEvent>(_onLogout);
    on<AppAuthRefreshProfileEvent>(_onRefreshProfile);
  }

  Future<void> _onCheck(
    AppAuthCheckEvent event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AppAuthLoadingState());
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        final uid = _authRepository.currentUser!.uid;
        final profile = await _authRepository.fetchUserProfile(uid);
        if (profile != null) {
          emit(AppAuthAuthenticatedState(profile));
        } else {
          emit(AppAuthAuthenticatedState(
            UserModel(
              uid: uid,
              email: _authRepository.currentUser!.email ?? '',
              username: _authRepository.currentUser!.displayName ?? 'User',
              isAnonymousMode: false,
              createdAt: DateTime.now(),
            ),
          ));
        }
      } else {
        emit(AppAuthUnauthenticatedState());
      }
    } catch (_) {
      emit(AppAuthUnauthenticatedState());
    }
  }

  Future<void> _onLogin(
    AppAuthLoginEvent event,
    Emitter<AppAuthState> emit,
  ) async {
    emit(AppAuthLoadingState());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      if (user != null) {
        emit(AppAuthAuthenticatedState(user));
      } else {
        emit(AppAuthErrorState('errorWrongPassword'));
      }
    } catch (e) {
      emit(AppAuthErrorState(mapFirebaseError(e)));
    }
  }

  Future<void> _onLogout(
    AppAuthLogoutEvent event,
    Emitter<AppAuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(AppAuthUnauthenticatedState());
  }

  Future<void> _onRefreshProfile(
    AppAuthRefreshProfileEvent event,
    Emitter<AppAuthState> emit,
  ) async {
    final current = state;
    if (current is! AppAuthAuthenticatedState) return;
    try {
      final profile = await _authRepository.fetchUserProfile(current.user.uid);
      if (profile != null) emit(AppAuthAuthenticatedState(profile));
    } catch (_) {}
  }
}
