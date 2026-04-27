import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../core/constants/app_constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthState()) {
    on<CheckLoginStatus>(_onCheckStatus);
    on<LoginWithCookies>(_onLoginWithCookies);
    on<LoginFromWebView>(_onLoginFromWebView);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckStatus(
    CheckLoginStatus event,
    Emitter<AuthState> emit,
  ) async {
    final loggedIn = await _repository.isLoggedIn();
    if (loggedIn) {
      final profile = await _repository.getUserProfile();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        profile: profile,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginWithCookies(
    LoginWithCookies event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _repository.saveLoginCookies(
        memberId: event.memberId,
        passHash: event.passHash,
        igneous: event.igneous,
      );

      final valid = await _repository.validateLogin();
      if (valid) {
        final profile = await _repository.getUserProfile();
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          profile: profile,
        ));
      } else {
        await _repository.logout();
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid cookies. Login verification failed.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoginFromWebView(
    LoginFromWebView event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final memberId = event.cookies[AppConstants.cookieIpbMemberId];
      final passHash = event.cookies[AppConstants.cookieIpbPassHash];
      final igneous = event.cookies[AppConstants.cookieIgneous];

      if (memberId == null || passHash == null) {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Required cookies not found after login.',
        ));
        return;
      }

      await _repository.saveLoginCookies(
        memberId: memberId,
        passHash: passHash,
        igneous: igneous,
      );

      final profile = await _repository.getUserProfile();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        profile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
