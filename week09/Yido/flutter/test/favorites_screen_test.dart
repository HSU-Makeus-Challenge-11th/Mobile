import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/app/movie_log_app.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_favorite_api.dart';
import 'support/fake_member_services.dart';
import 'support/fake_token_storage.dart';
import 'support/fake_tmdb_movie_service.dart';

void main() {
  late FakeFavoriteApi favorites;
  late FakeTmdbMovieService tmdb;
  late FakeMemberApiService member;

  Widget app() => MovieLogApp(
    favoriteApiService: favorites,
    signUpService: FakeSignUpService(),
    ratingApiService: FakeRatingApiService(),
    authApiService: FakeAuthApiService(),
    memberApiService: member,
    tokenStorage: FakeTokenStorage(),
    movieService: tmdb,
  );

  Future<void> openFavorites(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app());
    final context = tester.element(find.byType(Navigator).first);
    await context.read<AuthViewModel>().login('a@umc.com', 'Umc1234!');
    await tester.pumpAndSettle();
    AppRouter.router.push('/my/favorites');
    await tester.pumpAndSettle();
  }

  setUp(() {
    favorites = FakeFavoriteApi();
    tmdb = FakeTmdbMovieService(
      detailMovies: {
        550: fakeMovie(550, title: '별빛 아래 우리'),
        238: fakeMovie(238, title: '달빛 산책'),
      },
    );
    member = FakeMemberApiService();
  });

  testWidgets('list, detail removal and return refresh', (tester) async {
    favorites.movieIds.addAll([238, 550]);
    await openFavorites(tester);
    expect(find.text('내 즐겨찾기'), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(find.text('달빛 산책'), findsOneWidget);
    expect(find.byKey(const Key('tab_마이')), findsNothing);

    await tester.tap(find.text('별빛 아래 우리'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('favoriteButton')));
    await tester.tap(find.byKey(const Key('favoriteButton')));
    await tester.pumpAndSettle();
    expect(find.text('즐겨찾기에서 삭제했습니다.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('별빛 아래 우리'), findsNothing);
    expect(find.text('달빛 산책'), findsOneWidget);
  });

  testWidgets('empty state', (tester) async {
    await openFavorites(tester);
    expect(find.text('아직 즐겨찾기한 영화가 없습니다.'), findsOneWidget);
    expect(find.text('영화 상세에서 북마크를 눌러보세요.'), findsOneWidget);
  });

  testWidgets('a list error offers retry', (tester) async {
    favorites.listError = DioException(requestOptions: RequestOptions());
    await openFavorites(tester);
    expect(find.text('즐겨찾기를 불러오지 못했습니다.'), findsOneWidget);

    favorites.listError = null;
    favorites.movieIds.add(550);
    await tester.tap(find.byKey(const Key('w9RetryButton')));
    await tester.pumpAndSettle();
    expect(find.text('별빛 아래 우리'), findsOneWidget);
  });

  testWidgets('one failed movie shows a placeholder card with retry', (
    tester,
  ) async {
    favorites.movieIds.addAll([238, 550]);
    tmdb.failingDetailIds.add(238);
    await openFavorites(tester);
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(find.text('영화 #238'), findsOneWidget);
    expect(find.text('정보 다시 불러오기'), findsOneWidget);

    tmdb.failingDetailIds.clear();
    await tester.tap(find.text('정보 다시 불러오기'));
    await tester.pumpAndSettle();
    expect(find.text('달빛 산책'), findsOneWidget);
    expect(find.text('정보 다시 불러오기'), findsNothing);
  });

  testWidgets('another account never sees the previous list', (tester) async {
    favorites.movieIds.add(550);
    await openFavorites(tester);
    expect(find.text('별빛 아래 우리'), findsOneWidget);

    final context = tester.element(find.byType(Navigator).first);
    await context.read<AuthViewModel>().logout();
    await tester.pumpAndSettle();
    favorites.movieIds.clear(); // B 계정은 즐겨찾기가 없다
    member.member = MemberInfo(
      email: 'b@umc.com',
      nickname: '시네필B',
      createdAt: DateTime(2026, 11, 1),
    );
    await context.read<AuthViewModel>().login('b@umc.com', 'Umc1234!');
    await tester.pumpAndSettle();
    AppRouter.router.push('/my/favorites');
    await tester.pumpAndSettle();
    expect(find.text('별빛 아래 우리'), findsNothing);
    expect(find.text('아직 즐겨찾기한 영화가 없습니다.'), findsOneWidget);
  });
}
