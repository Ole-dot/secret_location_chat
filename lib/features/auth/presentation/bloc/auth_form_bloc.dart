import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthFormEvent {}

class AuthFormChangedEvent extends AuthFormEvent {
  final String email;
  final String password;
  AuthFormChangedEvent({required this.email, required this.password});
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthFormState {}

class AuthFormInitialState extends AuthFormState {}

class AuthFormValidState extends AuthFormState {}

class AuthFormInvalidState extends AuthFormState {
  final String? emailError;
  final String? passwordError;
  AuthFormInvalidState({this.emailError, this.passwordError});
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthFormBloc extends Bloc<AuthFormEvent, AuthFormState> {
  AuthFormBloc() : super(AuthFormInitialState()) {
    on<AuthFormChangedEvent>(_onChanged);
  }

  void _onChanged(
    AuthFormChangedEvent event,
    Emitter<AuthFormState> emit,
  ) {
    final emailError = _validateEmail(event.email);
    final passwordError = _validatePassword(event.password);

    if (emailError == null && passwordError == null) {
      emit(AuthFormValidState());
    } else {
      emit(AuthFormInvalidState(
        emailError: emailError,
        passwordError: passwordError,
      ));
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return null; // не показываем ошибку пока пусто
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(email)) return 'validationInvalidEmail';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return null;
    if (password.length < 6) return 'validationPasswordMin';
    return null;
  }
}
