import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:coo_list/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coo_list/config/app_router.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<ClearAuthErrorEvent>(_onClearAuthError);

    add(CheckAuthStatusEvent());
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final user = authRepository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.signUp(event.email, event.password);
      emit(RegistrationSuccess(event.email));
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.signIn(event.email, event.password);
      final user = authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError(
            'Bejelentkezés sikeres volt, de a felhasználó adatai nem sikerültek lekérdezni'));
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    await _clearUserPreferences();

    await authRepository.signOut();

    emit(const Unauthenticated());
  }

  Future<void> _onClearAuthError(
      ClearAuthErrorEvent event, Emitter<AuthState> emit) async {
    if (state is AuthError) {
      emit(const Unauthenticated());
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString();
      if (errorString.startsWith('Exception: ')) {
        return errorString.substring('Exception: '.length);
      }
      return errorString;
    }
    return error.toString();
  }

  Future<void> _clearUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppRouter.lastSelectedProfileKey);
  }
}
