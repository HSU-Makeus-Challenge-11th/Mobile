import 'package:deku/data/mock_movies.dart';
import 'package:deku/data/models/rating_request.dart';
import 'package:deku/data/models/rating.dart';
import 'package:deku/data/services/rating_api_service.dart';
import 'package:deku/data/services/favorite_api_service.dart';
import 'package:deku/data/models/favorite.dart';
import 'package:deku/screens/home/home_screen.dart';
import 'package:deku/screens/movies/movie_detail_screen.dart';
import 'package:deku/screens/movies/movie_list_screen.dart';
import 'package:deku/services/genre_preference.dart';
import 'package:deku/services/movie_service.dart';
import 'package:deku/theme/app_theme.dart';
import 'package:deku/widgets/movie_card.dart';
import 'package:deku/view_models/learning_member_session.dart';
import 'package:deku/view_models/auth_view_model.dart';
import 'package:deku/view_models/session_ratings_store.dart';
import 'package:deku/view_models/favorite_detail_view_model.dart';
import 'package:deku/data/services/auth_api_service.dart';
import 'package:deku/data/services/member_api_service.dart';
import 'package:deku/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('홈은 디자인 높이의 대표 카드와 세로 스크롤을 제공한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _testApp(
        HomeScreen(movieService: FakeMovieService(delay: Duration.zero)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-scroll-view')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('featured-movie-banner'))),
      const Size(358, 534),
    );
    // 가로 ListView는 화면에 보이는 카드만 lazy build한다.
    expect(find.byType(PopularMovieCard), findsAtLeastNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('영화 목록은 GridView와 장르 Chip 필터를 제공한다', (tester) async {
    _setSurface(tester, const Size(390, 844));
    await tester.pumpWidget(
      _testApp(
        MovieListScreen(
          movieService: FakeMovieService(delay: Duration.zero),
          genrePreferenceStore: _MemoryGenrePreference(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsAtLeastNWidgets(1));
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
    await tester.pumpAndSettle();

    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text('별빛 아래 우리'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('상세 화면은 평균 평점, 즐겨찾기 Snackbar, 필수 평점 Dialog를 제공한다', (
    tester,
  ) async {
    _setSurface(tester, const Size(390, 844));
    final session = LearningMemberSession()..setMemberId(42);
    final ratings = _FakeRatingApiService();
    final favorites = _FakeFavoriteApiService();
    final sessionRatings = SessionRatingsStore();
    final auth = AuthViewModel(
      AuthApiService(Dio()),
      MemberApiService(Dio()),
      _MemoryTokenStorage(),
      sessionRatings,
    )..status = AuthStatus.signedIn;
    await tester.pumpWidget(
      _testApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<LearningMemberSession>.value(value: session),
            ChangeNotifierProvider<AuthViewModel>.value(value: auth),
            ChangeNotifierProvider<SessionRatingsStore>.value(
              value: sessionRatings,
            ),
            Provider<RatingApiService>.value(value: ratings),
            ChangeNotifierProvider<FavoriteDetailViewModel>(
              create: (_) =>
                  FavoriteDetailViewModel(favorites, auth, movies.first.id)
                    ..load(),
            ),
          ],
          child: MovieDetailScreen(movie: movies.first),
        ),
      ),
    );

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

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('favorite-button')));
    await tester.pump();
    await tester.pump();
    expect(find.text('즐겨찾기에 추가했습니다.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-rating-dialog-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rating-dialog')), findsOneWidget);
    expect(find.byKey(const Key('movie-rating-input')), findsOneWidget);
    expect(find.text('다시 선택하기'), findsNothing);

    final stars = find.byKey(const Key('movie-rating-input'));
    await tester.tapAt(tester.getTopLeft(stars) + const Offset(160, 21));
    await tester.enterText(
      find.byKey(const Key('rating-comment-field')),
      '좋은 영화였어요',
    );
    await tester.tap(find.byKey(const Key('confirm-rating-button')));
    await tester.pumpAndSettle();
    expect(find.text('평점을 등록했습니다. 마이페이지에서 확인할 수 있습니다.'), findsOneWidget);
    expect(sessionRatings.ratings.single.movieId, movies.first.id);
    expect(ratings.request?.movieId, movies.first.id);
    expect(ratings.request?.score, inInclusiveRange(1, 5));
    expect(ratings.request?.comment, '좋은 영화였어요');
    expect(tester.takeException(), isNull);
  });
}

class _FakeRatingApiService extends RatingApiService {
  _FakeRatingApiService() : super(Dio());

  CreateRatingRequest? request;

  @override
  Future<Rating> createRating({required CreateRatingRequest request}) async {
    this.request = request;
    return Rating(ratingId: 1, movieId: request.movieId, score: request.score);
  }
}

class _FakeFavoriteApiService extends FavoriteApiService {
  _FakeFavoriteApiService() : super(Dio());

  bool saved = false;

  @override
  Future<bool> isFavorite(int movieId) async => saved;

  @override
  Future<Favorite> addFavorite(int movieId) async {
    saved = true;
    return Favorite(favoriteId: 1, movieId: movieId);
  }

  @override
  Future<void> removeFavorite(int movieId) async {
    saved = false;
  }
}

class _MemoryTokenStorage implements TokenStorage {
  @override
  Future<void> deleteAccessToken() async {}
  @override
  Future<String?> readAccessToken() async => null;
  @override
  Future<void> saveAccessToken(String token) async {}
}

final class _MemoryGenrePreference implements GenrePreferenceStore {
  int? genreId;

  @override
  Future<int?> read() async => genreId;

  @override
  Future<void> save(int? genreId) async {
    this.genreId = genreId;
  }
}

Widget _testApp(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

void _setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
