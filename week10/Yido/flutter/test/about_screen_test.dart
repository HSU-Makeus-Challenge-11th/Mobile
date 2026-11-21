import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/app/movie_log_app.dart';
import 'package:movielog/data/services/app_info_service.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/view_models/about_view_model.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_favorite_api.dart';
import 'support/fake_member_services.dart';
import 'support/fake_token_storage.dart';
import 'support/fake_tmdb_movie_service.dart';

class _FailingInfo extends AppInfoService {
  @override
  Future<String> getVersionLabel() async => throw StateError('no plugin');
}

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'MovieLog',
      packageName: 'com.makeus.movielog.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('my page ⓘ opens the about screen and back returns', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MovieLogApp(
        favoriteApiService: FakeFavoriteApi(),
        signUpService: FakeSignUpService(),
        ratingApiService: FakeRatingApiService(),
        authApiService: FakeAuthApiService(),
        memberApiService: FakeMemberApiService(),
        tokenStorage: FakeTokenStorage(),
        movieService: FakeTmdbMovieService(),
      ),
    );
    final context = tester.element(find.byType(Navigator).first);
    await context.read<AuthViewModel>().login('a@umc.com', 'Umc1234!');
    await tester.pumpAndSettle();
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();

    // ⓘ는 로그아웃 왼쪽에 있다
    final info = tester.getRect(find.byKey(const Key('aboutInfoButton')));
    final logout = tester.getRect(find.byKey(const Key('logoutButton')));
    expect(info.right, lessThanOrEqualTo(logout.left));

    await tester.tap(find.byKey(const Key('aboutInfoButton')));
    await tester.pumpAndSettle();
    expect(AppRouter.router.state.uri.path, '/my/about');
    expect(find.text('앱 정보'), findsOneWidget);
    expect(find.text('MovieLog'), findsOneWidget);
    expect(find.text('버전 1.0.0 (1)'), findsOneWidget);
    expect(find.byKey(const Key('aboutTmdbLogo')), findsOneWidget);
    expect(find.text('This product uses the TMDB API'), findsOneWidget);
    expect(find.text('but is not endorsed or certified'), findsOneWidget);
    expect(find.text('by TMDB.'), findsOneWidget);
    expect(find.byKey(const Key('tab_마이')), findsNothing);
    expect(
      find.byKey(const Key('aboutMovieLogLogo'), skipOffstage: false),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('w9BackButton')));
    await tester.pumpAndSettle();
    expect(AppRouter.router.state.uri.path, '/my');
  });

  test('a version read failure only changes the label', () async {
    final vm = AboutViewModel(_FailingInfo());
    await vm.load();
    expect(vm.versionLabel, '확인할 수 없음');
  });

  test('the label is version and build number', () async {
    expect(await AppInfoService().getVersionLabel(), '1.0.0 (1)');
  });
}
