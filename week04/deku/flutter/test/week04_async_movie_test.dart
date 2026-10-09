import 'package:deku/screens/movies/movie_list_screen.dart';
import 'package:deku/services/genre_preference.dart';
import 'package:deku/services/movie_service.dart';
import 'package:deku/theme/app_theme.dart';
import 'package:deku/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Future가 완료되기 전에 Loading 상태를 보여준다', (tester) async {
    await tester.pumpWidget(
      _testApp(
        MovieListScreen(
          movieService: FakeMovieService(
            delay: const Duration(milliseconds: 800),
          ),
          genrePreferenceStore: _MemoryGenrePreference(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byKey(const Key('movie-list-loading')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.byType(MovieCard), findsAtLeastNWidgets(1));
  });

  testWidgets('빈 결과는 Empty 상태로 표시한다', (tester) async {
    await tester.pumpWidget(
      _testApp(
        MovieListScreen(
          movieService: FakeMovieService(
            mode: MovieLoadMode.empty,
            delay: Duration.zero,
          ),
          genrePreferenceStore: _MemoryGenrePreference(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('movie-list-empty')), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets('오류 후 재시도하면 새 Future로 영화를 불러온다', (tester) async {
    await tester.pumpWidget(
      _testApp(
        MovieListScreen(
          movieService: FakeMovieService(
            mode: MovieLoadMode.failureOnce,
            delay: Duration.zero,
          ),
          genrePreferenceStore: _MemoryGenrePreference(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('movie-list-error')), findsOneWidget);
    expect(find.textContaining('MovieLoadException'), findsNothing);

    await tester.tap(find.byKey(const Key('movie-list-retry-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('movie-list-error')), findsNothing);
    expect(find.byType(MovieCard), findsAtLeastNWidgets(1));
  });

  testWidgets('선택한 장르를 저장하고 다시 열었을 때 복원한다', (tester) async {
    final preference = _MemoryGenrePreference(initialGenre: 'SF');

    await tester.pumpWidget(
      _testApp(
        MovieListScreen(
          movieService: FakeMovieService(delay: Duration.zero),
          genrePreferenceStore: preference,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_isChipSelected(tester, 'SF'), isTrue);
    expect(find.byType(MovieCard), findsNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('genre-filter-드라마')));
    await tester.pumpAndSettle();
    expect(preference.genre, '드라마');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _testApp(
        MovieListScreen(
          movieService: FakeMovieService(delay: Duration.zero),
          genrePreferenceStore: preference,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_isChipSelected(tester, '드라마'), isTrue);
    expect(find.byType(MovieCard), findsOneWidget);
  });
}

bool _isChipSelected(WidgetTester tester, String genre) {
  final chip = tester.widget<ChoiceChip>(
    find.byKey(ValueKey('genre-filter-$genre')),
  );
  return chip.selected;
}

Widget _testApp(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

final class _MemoryGenrePreference implements GenrePreferenceStore {
  _MemoryGenrePreference({String initialGenre = GenrePreference.defaultGenre})
    : genre = initialGenre;

  String genre;

  @override
  Future<String> read() async => genre;

  @override
  Future<void> save(String genre) async {
    this.genre = genre;
  }
}
