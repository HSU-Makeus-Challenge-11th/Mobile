import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/app/movie_log_app.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';
import 'package:movielog/widgets/back_arrow_icon.dart';
import 'package:provider/provider.dart';

import 'support/fake_auth_services.dart';
import 'support/fake_favorite_api.dart';
import 'support/fake_member_services.dart';
import 'support/fake_token_storage.dart';
import 'support/fake_tmdb_movie_service.dart';

Widget app({
  FakeRatingApiService? ratingService,
  FakeFavoriteApi? favoriteApi,
}) => MovieLogApp(
  favoriteApiService: favoriteApi ?? FakeFavoriteApi(),
  signUpService: FakeSignUpService(),
  ratingApiService: ratingService ?? FakeRatingApiService(),
  authApiService: FakeAuthApiService(),
  memberApiService: FakeMemberApiService(),
  tokenStorage: FakeTokenStorage(),
  movieService: FakeTmdbMovieService(
    popular: [for (var i = 1; i <= 5; i++) fakeMovie(i, title: '인기 $i')],
    discoverPages: {
      null: [
        [
          fakeMovie(10, title: '별빛 아래 우리', genreIds: [18]),
          fakeMovie(11, title: '우주의 끝에서'),
        ],
      ],
      878: [
        [fakeMovie(11, title: '우주의 끝에서')],
      ],
    },
  ),
);

Finder tab(String label) => find.byKey(Key('tab_$label'));

/// 가짜 로그인으로 세션을 만들고, 그 세션에서 등록한 평점을 넣어 둔다
Future<void> signIn(WidgetTester tester, {List ratings = const []}) async {
  final context = tester.element(find.byType(Navigator).first);
  await context.read<AuthViewModel>().login('a@umc.com', 'Umc1234!');
  final store = context.read<SessionRatingStore>();
  for (final rating in ratings.reversed) {
    store.put(rating, version: store.version);
  }
}

void main() {
  testWidgets('sign-up returns to login, then login reaches home', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    // 저장된 토큰이 없으면 스플래시 뒤 로그인 화면으로 간다
    expect(AppRouter.router.state.uri.path, '/login');
    await tester.ensureVisible(find.byKey(const Key('goSignUpButton')));
    await tester.tap(find.byKey(const Key('goSignUpButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('nicknameField')), 'Yido');
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'movie@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'Movie!1234',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('nicknameCheckButton')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('emailCheckButton')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('termsCheckbox')));
    await tester.tap(find.byKey(const Key('termsCheckbox')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('signUpButton')));
    await tester.tap(find.byKey(const Key('signUpButton')));
    await tester.pumpAndSettle();
    expect(AppRouter.router.state.uri.path, '/login');
    expect(find.text('회원가입을 완료했습니다. 로그인해 주세요.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('loginEmailField')),
      'a@umc.com',
    );
    await tester.enterText(
      find.byKey(const Key('loginPasswordField')),
      'Umc1234!',
    );
    await tester.ensureVisible(find.byKey(const Key('loginButton')));
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle();
    expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsOneWidget);
    await tester.tap(tab('영화'));
    await tester.pumpAndSettle();
    expect(find.text('전체'), findsOneWidget);
  });

  testWidgets('my page opens ratings without the tab bar and comes back', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await signIn(tester, ratings: [fakeRating(1)]);
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.ensureVisible(find.text('내가 등록한 평점'));
    await tester.tap(find.text('내가 등록한 평점'));
    await tester.pumpAndSettle();
    expect(AppRouter.router.state.uri.path, '/my/ratings');
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('최고의 영화!'), findsOneWidget);
    expect(find.text('영화 #550'), findsOneWidget);

    await tester.tap(find.byType(BackArrowIcon));
    await tester.pumpAndSettle();
    expect(find.text('내 프로필'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('edit opens prefilled, delete asks first and shows Empty', (
    tester,
  ) async {
    final api = FakeRatingApiService();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(ratingService: api));
    await signIn(tester, ratings: [fakeRating(7, comment: '다시 봐도 좋아요')]);
    AppRouter.router.go('/my/ratings');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('editRating_7')));
    await tester.pumpAndSettle();
    expect(find.text('평점을 남겨주세요'), findsOneWidget);
    expect(find.text('다시 봐도 좋아요'), findsNWidgets(2));
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(api.updated, isEmpty);

    await tester.tap(find.byKey(const Key('deleteRating_7')));
    await tester.pumpAndSettle();
    expect(find.text('평점을 삭제할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(api.deleted, isEmpty);

    await tester.tap(find.byKey(const Key('deleteRating_7')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteButton')));
    await tester.pumpAndSettle();
    expect(api.deleted.single, 7);
    expect(find.text('평점을 삭제할까요?'), findsNothing);
    expect(find.text('등록된 평점이 없습니다'), findsOneWidget);
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();
  });

  testWidgets('a rating created on the detail shows on my ratings', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await signIn(tester);
    AppRouter.router.go('/my/ratings');
    await tester.pumpAndSettle();
    expect(find.text('등록된 평점이 없습니다'), findsOneWidget);
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();
  });

  testWidgets('movie filter, detail favorite and rating confirmation work', (
    tester,
  ) async {
    final ratingService = FakeRatingApiService();
    final favoriteApi = FakeFavoriteApi();
    await tester.pumpWidget(
      app(ratingService: ratingService, favoriteApi: favoriteApi),
    );
    await signIn(tester);
    AppRouter.router.go('/movies');
    await tester.pumpAndSettle();
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    await tester.tap(find.text('SF'));
    await tester.pumpAndSettle();
    expect(find.text('우주의 끝에서'), findsOneWidget);
    final movieCard = find
        .ancestor(
          of: find.text('우주의 끝에서'),
          matching: find.byType(GestureDetector),
        )
        .first;
    await tester.ensureVisible(movieCard);
    await tester.tap(movieCard);
    await tester.pumpAndSettle();
    expect(find.text('Cinema Archive'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('favoriteButton')));
    await tester.tap(find.byKey(const Key('favoriteButton')));
    await tester.pumpAndSettle();
    expect(find.text('즐겨찾기에 추가했습니다.'), findsOneWidget);
    expect(favoriteApi.movieIds, {11});
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('openRatingButton')))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.text('평점 남기기'));
    await tester.pumpAndSettle();
    expect(find.text('평점을 남겨주세요'), findsOneWidget);
    final confirm = find.descendant(
      of: find.byKey(const Key('confirmRatingButton')),
      matching: find.byType(ElevatedButton),
    );
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
    final stars = find.descendant(
      of: find.byType(RatingBar),
      matching: find.byType(GestureDetector),
    );
    await tester.tapAt(tester.getRect(stars.at(3)).center);
    await tester.pump();
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.textContaining('평점을 등록했습니다.'), findsOneWidget);
    expect(ratingService.created.single.movieId, 11);
    expect(ratingService.created.single.score, 4);
    await tester.ensureVisible(find.byKey(const Key('favoriteButton')));
    await tester.tap(find.byKey(const Key('favoriteButton')));
    await tester.pumpAndSettle();
    expect(find.text('즐겨찾기에서 삭제했습니다.'), findsOneWidget);
    expect(favoriteApi.movieIds, isEmpty);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('우주의 끝에서'), findsOneWidget);
  });

  testWidgets('390 and 360 viewports lay out shell screens without overflow', (
    tester,
  ) async {
    for (final size in const [Size(390, 844), Size(360, 800)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(app());
      for (final path in [
        '/home',
        '/movies',
        '/my',
        '/my/ratings',
        '/register',
        '/movies/1',
      ]) {
        AppRouter.router.go(path);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$path at $size');
      }
    }
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'iOS tabs replace shell content without an intermediate overlap',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(app());
        await signIn(tester);
        AppRouter.router.go('/home');
        await tester.pumpAndSettle();

        await tester.tap(tab('영화'));
        await tester.pump();
        expect(find.text('전체'), findsOneWidget);
        expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsNothing);
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsNothing);

        await tester.tap(tab('마이'));
        await tester.pump();
        expect(find.text('내 프로필'), findsOneWidget);
        expect(find.text('전체'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('iOS Manrope profile line boxes fit their CSS heights', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      final fontLoader = FontLoader(
        'Manrope',
      )..addFont(rootBundle.load('assets/fonts/Manrope-VariableFont_wght.ttf'));
      await fontLoader.load();
      await tester.binding.setSurfaceSize(const Size(390, 844));

      final auth = AuthViewModel(
        FakeAuthApiService(),
        FakeMemberApiService(),
        FakeTokenStorage(),
      );
      await auth.login('a@umc.com', 'Umc1234!');
      await auth.loadMember();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: auth,
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();
      // W8-06: 닉네임 25, 이메일 16, 통계 라벨 15, 숫자 29
      expect(tester.getSize(find.text('시네필A')).height, 25);
      expect(tester.getSize(find.text('a@umc.com')).height, 16);
      expect(tester.getSize(find.text('본 영화')).height, 16);
      expect(tester.getSize(find.text('342')).height, 31);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.binding.setSurfaceSize(null);
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
