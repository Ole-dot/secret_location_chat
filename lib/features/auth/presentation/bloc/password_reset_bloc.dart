import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';

abstract class PasswordResetEvent {}

class PasswordResetSubmitEvent extends PasswordResetEvent {
  final String email;
  /// Язык письма Firebase: `ru` или `kk`. Null — авто по локали устройства.
  final String? languageCode;

  PasswordResetSubmitEvent(this.email, {this.languageCode});
}

abstract class PasswordResetState {}

class PasswordResetInitialState extends PasswordResetState {}

class PasswordResetLoadingState extends PasswordResetState {}

class PasswordResetSuccessState extends PasswordResetState {}

class PasswordResetErrorState extends PasswordResetState {
  final String message;
  PasswordResetErrorState(this.message);
}

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository _repo;

  PasswordResetBloc(this._repo) : super(PasswordResetInitialState()) {
    on<PasswordResetSubmitEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    PasswordResetSubmitEvent event,
    Emitter<PasswordResetState> emit,
  ) async {
    final email = event.email.trim();
    if (email.isEmpty) {
      emit(PasswordResetErrorState('errorEnterEmail'));
      return;
    }

    emit(PasswordResetLoadingState());
    try {
      await _repo.sendPasswordResetEmail(
        email,
        languageCode: event.languageCode,
      );
      emit(PasswordResetSuccessState());
    } catch (e) {
      emit(PasswordResetErrorState(mapFirebaseError(e)));
    }
  }
}
