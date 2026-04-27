import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String? memberId;
  final String? passHash;
  final String? igneous;
  final String? displayName;
  final String? avatarUrl;
  final bool isLoggedIn;

  const UserProfile({
    this.memberId,
    this.passHash,
    this.igneous,
    this.displayName,
    this.avatarUrl,
    this.isLoggedIn = false,
  });

  const UserProfile.guest()
      : memberId = null,
        passHash = null,
        igneous = null,
        displayName = null,
        avatarUrl = null,
        isLoggedIn = false;

  @override
  List<Object?> get props => [memberId, isLoggedIn];
}
