import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:oviewer/blocs/auth/auth_bloc.dart';
import 'package:oviewer/blocs/auth/auth_event.dart';
import 'package:oviewer/blocs/auth/auth_state.dart';
import 'package:oviewer/repositories/auth_repository.dart';
import 'package:oviewer/models/user_profile.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'CheckLoginStatus emits authenticated when logged in',
      setUp: () {
        when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockRepo.getUserProfile()).thenAnswer(
          (_) async => const UserProfile(
            memberId: '12345',
            isLoggedIn: true,
          ),
        );
      },
      build: () => AuthBloc(mockRepo),
      act: (bloc) => bloc.add(CheckLoginStatus()),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having(
                (s) => s.profile.memberId, 'memberId', '12345'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'CheckLoginStatus emits unauthenticated when not logged in',
      setUp: () {
        when(() => mockRepo.isLoggedIn()).thenAnswer((_) async => false);
      },
      build: () => AuthBloc(mockRepo),
      act: (bloc) => bloc.add(CheckLoginStatus()),
      expect: () => [
        isA<AuthState>().having(
            (s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'LogoutRequested clears session',
      setUp: () {
        when(() => mockRepo.logout()).thenAnswer((_) async {});
      },
      build: () => AuthBloc(mockRepo),
      seed: () => const AuthState(
        status: AuthStatus.authenticated,
        profile: UserProfile(memberId: '123', isLoggedIn: true),
      ),
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        isA<AuthState>().having(
            (s) => s.status, 'status', AuthStatus.unauthenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'LoginWithCookies validates and emits authenticated',
      setUp: () {
        when(() => mockRepo.saveLoginCookies(
              memberId: any(named: 'memberId'),
              passHash: any(named: 'passHash'),
              igneous: any(named: 'igneous'),
            )).thenAnswer((_) async {});
        when(() => mockRepo.validateLogin())
            .thenAnswer((_) async => true);
        when(() => mockRepo.getUserProfile()).thenAnswer(
          (_) async =>
              const UserProfile(memberId: '99', isLoggedIn: true),
        );
      },
      build: () => AuthBloc(mockRepo),
      act: (bloc) => bloc.add(const LoginWithCookies(
        memberId: '99',
        passHash: 'hash123',
      )),
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated),
      ],
    );
  });
}
