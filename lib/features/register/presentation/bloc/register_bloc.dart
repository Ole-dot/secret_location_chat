import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secret_location_chat/core/auth/firebase_error_messages.dart';
import 'package:secret_location_chat/data/auth/auth_repository.dart';
import 'package:secret_location_chat/data/models/user_model.dart';

abstract class RegisterEvent {}

class RegisterSubmitEvent extends RegisterEvent {
  final String email;
  final String password;
  final String username;
  RegisterSubmitEvent({required this.email, required this.password, required this.username});
}

abstract class RegisterState {}

class RegisterInitialState extends RegisterState {}
class RegisterLoadingState extends RegisterState {}
class RegisterSuccessState extends RegisterState {
  final UserModel user;
  RegisterSuccessState(this.user);
}
class RegisterErrorState extends RegisterState {
  final String message;
  RegisterErrorState(this.message);
}

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _repo;
  RegisterBloc(this._repo) : super(RegisterInitialState()) {
    on<RegisterSubmitEvent>(_onSubmit);
  }

  Future<void> _onSubmit(RegisterSubmitEvent event, Emitter<RegisterState> emit) async {
    emit(RegisterLoadingState());
    try {
      final user = await _repo.register(
        email: event.email,
        password: event.password,
        username: event.username,
      );
      if (user != null) {
        emit(RegisterSuccessState(user));
      } else {
        emit(RegisterErrorState('Не удалось создать аккаунт'));
      }
    } catch (e) {
      emit(RegisterErrorState(mapFirebaseError(e)));
    }
  }
}
