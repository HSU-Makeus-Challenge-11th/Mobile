import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/app/movie_log_app.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_favorite_api.dart';
import 'support/fake_member_services.dart';
import 'support/fake_token_storage.dart';
import 'support/fake_tmdb_movie_service.dart';

void main() {
  late FakeTmdbMovieService tmdb;

  Future<void> openSearch(WidgetTester tester) async {
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
        movieService: tmdb,
      ),
    );
    final context = tester.element(find.byType(Navigator).first);
    await context.read<AuthViewModel>().login('a@umc.com', 'Umc1234!');
    await tester.pumpAndSettle();
    AppRouter.router.go('/movies');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSearchButton')));
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byKey(const Key('searchField')), query);
    await tester.tap(find.byKey(const Key('searchSubmitButton')));
    await tester.pumpAndSettle();
  }

  setUp(() {
    tmdb = FakeTmdbMovieService(
      discoverPages: {
        null: [
          [fakeMovie(1)],
        ],
      },
      detailMovies: {550: fakeMovie(550, title: '별빛 아래 우리')},
    );
    tmdb.searchPages['별빛'] = [
      [fakeMovie(550, title: '별빛 아래 우리')],
      [fakeMovie(551, title: '별빛 산책')],
    ];
  });

  testWidgets('search opens without the bottom bar and needs a query', (
    tester,
  ) async {
    await openSearch(tester);
    expect(AppRouter.router.state.uri.path, '/movies/search');
    expect(find.text('영화 검색'), findsOneWidget);
    expect(find.byKey(const Key('tab_영화')), findsNothing);
    await search(tester, '   ');
    expect(find.byKey(const Key('searchInputError')), findsOneWidget);
    expect(tmdb.searchCalls, isEmpty);
  });

  testWidgets('results page with more and open the detail', (tester) async {
    await openSearch(tester);
    await search(tester, '별빛');
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(find.text('검색 결과 더 보기'), findsOneWidget);
    await tester.tap(find.text('검색 결과 더 보기'));
    await tester.pumpAndSettle();
    expect(find.text('별빛 산책'), findsOneWidget);
    expect(find.text('모든 검색 결과를 확인했습니다.'), findsOneWidget);

    await tester.tap(find.text('별빛 아래 우리'));
    await tester.pumpAndSettle();
    expect(AppRouter.router.state.uri.path, '/movies/550');
  });

  testWidgets('empty and error results are different', (tester) async {
    await openSearch(tester);
    await search(tester, '없는 영화');
    expect(find.text('검색 결과가 없습니다.'), findsOneWidget);
    tmdb.fail = true;
    await search(tester, '별빛');
    expect(find.text('검색 결과를 불러오지 못했습니다.'), findsOneWidget);
    tmdb.fail = false;
    await tester.tap(find.byKey(const Key('w9RetryButton')));
    await tester.pumpAndSettle();
    expect(find.text('별빛 아래 우리'), findsOneWidget);
  });

  testWidgets('a slow answer for the old query never replaces new results', (
    tester,
  ) async {
    tmdb.searchPages['달빛'] = [
      [fakeMovie(700, title: '달빛 영화')],
    ];
    final gate = Completer<void>();
    tmdb.delay = (page, _, query) =>
        query == '별빛' ? gate.future : Future.value();
    await openSearch(tester);
    await tester.enterText(find.byKey(const Key('searchField')), '별빛');
    await tester.tap(find.byKey(const Key('searchSubmitButton')));
    await tester.pump();
    await search(tester, '달빛');
    expect(find.text('달빛 영화'), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('달빛 영화'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsNothing);
  });
}
