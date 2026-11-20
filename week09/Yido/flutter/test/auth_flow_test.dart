import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/app/movie_log_app.dart';
import 'package:movielog/router/app_router.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_member_services.dart';
import 'support/fake_tmdb_movie_service.dart';
import 'support/fake_token_storage.dart';

class _Fakes {
  final auth = FakeAuthApiService();
  final member = FakeMemberApiService();
  final ratings = FakeRatingApiService();
  late final FakeTokenStorage storage;

  _Fakes([String? token]) : storage = FakeTokenStorage(token);

  Widget app() => MovieLogApp(
    signUpService: FakeSignUpService(),
    ratingApiService: ratings,
    authApiService: auth,
    memberApiService: member,
    tokenStorage: storage,
    movieService: FakeTmdbMovieService(popular: [fakeMovie(1)]),
  );
}

String path() => AppRouter.router.state.uri.path;

Future<void> pumpPhone(WidgetTester tester, Widget app) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(app);
}

Future<void> login(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byKey(const Key('loginEmailField')), email);
  await tester.enterText(find.byKey(const Key('loginPasswordField')), password);
  await tester.tap(find.byKey(const Key('loginButton')));
}

void main() {
  testWidgets('splash waits for GET me, then retry recovers', (tester) async {
    final fakes = _Fakes('saved.token');
    fakes.member.gate = Completer();
    await pumpPhone(tester, fakes.app());
    await tester.pump();
    expect(path(), '/start');
    expect(find.byKey(const Key('splashProgress')), findsOneWidget);

    // 네트워크 실패는 토큰을 지우지 않고 재시도 화면을 보여 준다
    fakes.member.error = networkError('/v8/members/me');
    fakes.member.gate!.complete();
    await tester.pumpAndSettle();
    expect(path(), '/start');
    expect(find.text('로그인 상태를 확인하지 못했어요.'), findsOneWidget);
    expect(fakes.storage.token, 'saved.token');

    fakes.member.gate = null;
    fakes.member.error = null;
    await tester.tap(find.byKey(const Key('splashRetryButton')));
    await tester.pumpAndSettle();
    expect(path(), '/home');
  });

  testWidgets('an expired stored token goes to login with one notice', (
    tester,
  ) async {
    final fakes = _Fakes('expired.token');
    fakes.member.error = apiError('/v8/members/me', 401, 'AUTH401_4');
    await pumpPhone(tester, fakes.app());
    await tester.pumpAndSettle();
    expect(path(), '/login');
    expect(find.text('로그인이 만료됐어요. 다시 로그인해 주세요.'), findsOneWidget);
    expect(fakes.storage.token, isNull);
  });

  testWidgets('signed out cannot open protected screens', (tester) async {
    final fakes = _Fakes();
    await pumpPhone(tester, fakes.app());
    await tester.pumpAndSettle();
    for (final protected in ['/home', '/my', '/my/ratings', '/movies/1']) {
      AppRouter.router.go(protected);
      await tester.pumpAndSettle();
      expect(path(), '/login', reason: protected);
    }
  });

  testWidgets('login validates, shows the failure, then signs in', (
    tester,
  ) async {
    final fakes = _Fakes();
    await pumpPhone(tester, fakes.app());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();
    expect(find.text('이메일을 입력해 주세요.'), findsOneWidget);
    expect(find.text('비밀번호를 입력해 주세요.'), findsOneWidget);
    expect(fakes.auth.requests, isEmpty);

    fakes.auth.error = apiError('/v8/auth/login', 401, 'AUTH401_1');
    await login(tester, 'a@umc.com', 'Wrong123!');
    await tester.pumpAndSettle();
    expect(path(), '/login');
    expect(find.text('이메일 또는 비밀번호를 확인해 주세요.'), findsOneWidget);
    // 로그인 실패는 만료 안내를 띄우지 않는다
    expect(find.text('로그인이 만료됐어요. 다시 로그인해 주세요.'), findsNothing);

    fakes.auth.error = null;
    fakes.auth.gate = Completer();
    await login(tester, 'a@umc.com', 'Umc1234!');
    await tester.pump();
    // 요청 중에는 버튼이 꺼지고 인디케이터만 보인다 (W8-04)
    final button = tester.widget<ElevatedButton>(
      find.descendant(
        of: find.byKey(const Key('loginButton')),
        matching: find.byType(ElevatedButton),
      ),
    );
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    fakes.auth.gate!.complete();
    await tester.pumpAndSettle();
    expect(path(), '/home');
    expect(fakes.storage.token, 'new.token.value');
    // 탭 화면이 처음 열릴 때 내 정보를 한 번 불러온다
    expect(fakes.member.fetchCount, 1);
  });

  testWidgets('my page shows GET me and logout returns to login', (
    tester,
  ) async {
    final fakes = _Fakes('saved.token');
    await pumpPhone(tester, fakes.app());
    await tester.pumpAndSettle();
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();
    expect(find.text('시네필A'), findsOneWidget);
    expect(find.text('a@umc.com'), findsOneWidget);

    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle();
    expect(path(), '/login');
    expect(fakes.storage.token, isNull);
    expect(find.text('로그인이 만료됐어요. 다시 로그인해 주세요.'), findsNothing);
  });

  testWidgets('profile edit keeps input on 409 and updates my page', (
    tester,
  ) async {
    final fakes = _Fakes('saved.token');
    await pumpPhone(tester, fakes.app());
    await tester.pumpAndSettle();
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editProfileButton')));
    await tester.pumpAndSettle();
    expect(path(), '/my/profile/edit');
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('4 / 12'), findsOneWidget);

    fakes.member.error = apiError('/v8/members/me', 409, 'MEMBER409_1');
    await tester.enterText(
      find.byKey(const Key('profileNicknameField')),
      '영화광B',
    );
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();
    expect(find.text('이미 사용 중인 닉네임이에요.'), findsOneWidget);
    expect(find.text('영화광B'), findsOneWidget);
    expect(path(), '/my/profile/edit');

    fakes.member.error = null;
    await tester.enterText(
      find.byKey(const Key('profileNicknameField')),
      '새닉네임',
    );
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();
    expect(path(), '/my');
    expect(find.text('프로필을 수정했어요.'), findsOneWidget);
    expect(find.text('새닉네임'), findsOneWidget);
  });

  testWidgets('an expired token while saving goes to login', (tester) async {
    final fakes = _Fakes('saved.token');
    await pumpPhone(tester, fakes.app());
    await tester.pumpAndSettle();
    AppRouter.router.go('/my/profile/edit');
    await tester.pumpAndSettle();
    fakes.member.error = apiError('/v8/members/me', 401, 'AUTH401_3');
    await tester.enterText(
      find.byKey(const Key('profileNicknameField')),
      '새닉네임',
    );
    await tester.tap(find.byKey(const Key('saveProfileButton')));
    await tester.pumpAndSettle();
    expect(path(), '/login');
    expect(find.text('로그인이 만료됐어요. 다시 로그인해 주세요.'), findsOneWidget);
  });
}
