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

  Future<void> openList(WidgetTester tester) async {
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
  }

  setUp(() {
    tmdb = FakeTmdbMovieService(
      discoverPages: {
        null: [
          [fakeMovie(1, title: '첫 영화'), fakeMovie(2, title: '둘째 영화')],
          [fakeMovie(3, title: '셋째 영화')],
        ],
      },
    );
  });

  testWidgets('scrolling near the end loads the next page by itself', (
    tester,
  ) async {
    tmdb = FakeTmdbMovieService(
      discoverPages: {
        null: [
          [for (var i = 1; i <= 8; i++) fakeMovie(i, title: '영화 $i')],
          [for (var i = 9; i <= 16; i++) fakeMovie(i, title: '영화 $i')],
        ],
      },
    );
    await openList(tester);
    expect(tmdb.discoverCalls.map((call) => call.page), [1]);
    expect(find.byKey(const Key('loadMoreButton')), findsNothing);

    final gate = Completer<void>();
    tmdb.delay = (page, _, _) => gate.future;
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -2000));
    await tester.pump();
    expect(find.byKey(const Key('autoLoadSpinner')), findsOneWidget);
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -500));
    await tester.pump();
    expect(tmdb.discoverCalls.where((call) => call.page == 2), hasLength(1));
    gate.complete();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('pageEndText')),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('모든 영화를 확인했습니다.'), findsOneWidget);
  });

  testWidgets('a failed next page shows the retry button', (tester) async {
    tmdb.failOncePages.add(2);
    await openList(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('loadMoreButton')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('추가 영화 조회에 실패했습니다.'), findsOneWidget);
    expect(find.text('다음 페이지 다시 시도'), findsOneWidget);
    expect(tmdb.discoverCalls.map((call) => call.page), [1, 2]);
    await tester.tap(find.byKey(const Key('loadMoreButton')));
    await tester.pumpAndSettle();
    expect(tmdb.discoverCalls.map((call) => call.page), [1, 2, 2]);
    expect(find.text('셋째 영화'), findsOneWidget);
  });
}
