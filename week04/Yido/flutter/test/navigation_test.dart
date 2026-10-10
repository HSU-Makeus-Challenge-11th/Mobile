import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/movie_log_app.dart';
import 'package:movielog/profile_screen.dart';
import 'package:movielog/router/app_router.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('registration reaches home and tab route changes', (
    tester,
  ) async {
    await tester.pumpWidget(const MovieLogApp());
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('회원가입'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('nicknameField')), 'Yido');
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'movie@example.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'movie1234');
    await tester.ensureVisible(find.byKey(const Key('termsCheckbox')));
    await tester.tap(find.byKey(const Key('termsCheckbox')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('signUpButton')));
    await tester.tap(find.byKey(const Key('signUpButton')));
    await tester.pumpAndSettle();
    expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsOneWidget);
    await tester.tap(find.text('영화').last);
    await tester.pumpAndSettle();
    expect(find.text('전체'), findsOneWidget);
  });

  testWidgets('movie filter, detail favorite and rating confirmation work', (
    tester,
  ) async {
    await tester.pumpWidget(const MovieLogApp());
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
    await tester.tap(find.text('평점 남기기'));
    await tester.pumpAndSettle();
    expect(find.text('영화는 어떠셨나요?'), findsOneWidget);
    final stars = find.descendant(
      of: find.byType(RatingBar),
      matching: find.byType(GestureDetector),
    );
    final bounds = tester.getRect(stars.at(3));
    await tester.tapAt(bounds.center);
    await tester.pump();
    final confirm = find.byKey(const Key('confirmRatingButton'));
    expect(tester.widget<FilledButton>(confirm).onPressed, isNotNull);
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(find.textContaining('점'), findsWidgets);
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
      await tester.pumpWidget(const MovieLogApp());
      for (final path in ['/home', '/movies', '/my', '/movies/starlight']) {
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
        await tester.pumpWidget(const MovieLogApp());
        AppRouter.router.go('/home');
        await tester.pumpAndSettle();

        await tester.tap(find.text('영화').last);
        await tester.pump();
        expect(find.text('전체'), findsOneWidget);
        expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsNothing);
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.text('오늘은 어떤\n영화를 볼까요?'), findsNothing);

        await tester.tap(find.text('마이').last);
        await tester.pump();
        expect(find.text('내 프로필'), findsOneWidget);
        expect(find.text('전체'), findsNothing);
        // 영화 목록의 1초 Mock 요청이 끝날 때까지 기다린다
        await tester.pump(const Duration(seconds: 1));
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
      expect(tester.getSize(find.text('무비러버')).height, 28);
      expect(tester.getSize(find.text('본 영화')).height, 16);
      expect(tester.getSize(find.text('342')).height, 28);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.binding.setSurfaceSize(null);
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
