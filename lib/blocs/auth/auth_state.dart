import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserProfile profile;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.profile = const UserProfile.guest(),
    this.errorMessage,
  });

  bool get isLoggedIn => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
