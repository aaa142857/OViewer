import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckLoginStatus extends AuthEvent {}

class LoginWithCookies extends AuthEvent {
  final String memberId;
  final String passHash;
  final String? igneous;
  const LoginWithCookies({
    required this.memberId,
    required this.passHash,
    this.igneous,
  });
  @override
  List<Object?> get props => [memberId, passHash, igneous];
}

class LoginFromWebView extends AuthEvent {
  final Map<String, String> cookies;
  const LoginFromWebView(this.cookies);
  @override
  List<Object?> get props => [cookies];
}

class LogoutRequested extends AuthEvent {}
