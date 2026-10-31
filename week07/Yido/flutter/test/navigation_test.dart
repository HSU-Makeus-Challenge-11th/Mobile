import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/app/movie_log_app.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:movielog/widgets/back_arrow_icon.dart';
import 'package:provider/provider.dart';

import 'support/fake_member_services.dart';
import 'support/fake_tmdb_movie_service.dart';

Widget app({FakeRatingApiService? ratingService}) => MovieLogApp(
  signUpService: FakeSignUpService(),
  ratingApiService:
      ratingService ?? FakeRatingApiService(ratings: [fakeRating(1)]),
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

void main() {
  testWidgets('registration reaches home and tab route changes', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    AppRouter.router.go('/start');
    await tester.pumpAndSettle();
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('회원가입'), findsOneWidget);
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
    // 가입에 성공하면 memberId를 세션에 저장하고 영화 목록으로 이동한다
    expect(find.text('전체'), findsOneWidget);
    expect(find.text('회원가입을 완료했습니다. (memberId: 77)'), findsOneWidget);
    await tester.tap(tab('홈'));
    await tester.pumpAndSettle();
    expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsOneWidget);
  });

  testWidgets('my page opens ratings without the tab bar and comes back', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    tester
        .element(find.byType(Navigator).first)
        .read<LearningMemberSession>()
        .setMemberId(1);
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
    final api = FakeRatingApiService(
      ratings: [fakeRating(7, comment: '다시 봐도 좋아요')],
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(ratingService: api));
    tester
        .element(find.byType(Navigator).first)
        .read<LearningMemberSession>()
        .setMemberId(1);
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
    api.ratings = const [];
    await tester.tap(find.byKey(const Key('confirmDeleteButton')));
    await tester.pumpAndSettle();
    expect(api.deleted.single.ratingId, 7);
    expect(find.text('평점을 삭제할까요?'), findsNothing);
    expect(find.text('등록된 평점이 없습니다'), findsOneWidget);
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();
  });

  testWidgets('without a member the ratings screen asks to sign up', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    AppRouter.router.go('/my/ratings');
    await tester.pumpAndSettle();
    expect(find.text('학습용 회원가입이 필요합니다.'), findsOneWidget);
    AppRouter.router.go('/my');
    await tester.pumpAndSettle();
  });

  testWidgets('movie filter, detail favorite and rating confirmation work', (
    tester,
  ) async {
    final ratingService = FakeRatingApiService();
    await tester.pumpWidget(app(ratingService: ratingService));
    tester
        .element(find.byType(Navigator).first)
        .read<LearningMemberSession>()
        .setMemberId(77);
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
    await tester.tap(find.text('즐겨찾기'));
    await tester.pump();
    expect(find.text('즐겨찾기에 추가했습니다.'), findsOneWidget);
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
    expect(ratingService.created.single.memberId, 77);
    expect(ratingService.created.single.request.movieId, 11);
    expect(ratingService.created.single.request.score, 4);
    await tester.tap(find.text('즐겨찾기'));
    await tester.pump();
    expect(find.byIcon(Icons.bookmark_border), findsWidgets);
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

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.text('무비러버')).height, 27);
      expect(tester.getSize(find.text('본 영화')).height, 16);
      expect(tester.getSize(find.text('342')).height, 31);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.binding.setSurfaceSize(null);
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
