import 'package:deku/data/mock_movies.dart';
import 'package:deku/screens/home/home_screen.dart';
import 'package:deku/screens/movies/movie_detail_screen.dart';
import 'package:deku/screens/movies/movie_list_screen.dart';
import 'package:deku/theme/app_theme.dart';
import 'package:deku/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('홈은 디자인 높이의 대표 카드와 세로 스크롤을 제공한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_testApp(const HomeScreen()));

    expect(find.byKey(const Key('home-scroll-view')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('featured-movie-banner'))),
      const Size(358, 534),
    );
    expect(find.byType(PopularMovieCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('영화 목록은 GridView와 장르 Chip 필터를 제공한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_testApp(const MovieListScreen()));

    expect(find.byType(MovieCard), findsNWidgets(movies.length));
    expect(find.byKey(const Key('movie-list-scroll-view')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('movie-card-1'))),
      const Size(171, 316.5),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('movie-title-1'))),
      const Size(171, 24),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('movie-metadata-1'))),
      const Size(171, 24),
    );
    expect(find.byKey(const ValueKey('genre-filter-전체')), findsOneWidget);
    expect(find.byKey(const ValueKey('genre-filter-드라마')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('genre-filter-드라마')));
    await tester.pump();

    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('상세 화면은 평균 평점, 즐겨찾기 Snackbar, 필수 평점 Dialog를 제공한다', (
    tester,
  ) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(_testApp(MovieDetailScreen(movie: movies.first)));

    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(find.byKey(const Key('average-rating-indicator')), findsOneWidget);
    expect(find.byKey(const Key('movie-detail-scroll-view')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('detail-hero-poster'))),
      const Size(390, 585),
    );
    expect(
      tester.getSize(find.byKey(const Key('detail-information-section'))),
      const Size(390, 216),
    );
    expect(
      tester.getSize(find.byKey(const Key('detail-title-line'))),
      const Size(358, 36),
    );
    expect(
      tester.getSize(find.byKey(const Key('detail-metadata-line'))),
      const Size(358, 20),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('detail-genre-로맨스'))),
      const Size(63, 28),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('detail-genre-드라마'))),
      const Size(63, 28),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('detail-genre-감동적인'))),
      const Size(76, 28),
    );

    await tester.tap(find.byKey(const Key('favorite-button')));
    await tester.pump();
    expect(find.text('즐겨찾기에 추가했습니다.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-rating-dialog-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rating-dialog')), findsOneWidget);
    expect(find.byKey(const Key('movie-rating-input')), findsOneWidget);
    expect(find.text('다시 선택하기'), findsNothing);

    await tester.tap(find.byKey(const Key('confirm-rating-button')));
    await tester.pumpAndSettle();
    expect(find.text('평점 3.5점을 남겼습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
