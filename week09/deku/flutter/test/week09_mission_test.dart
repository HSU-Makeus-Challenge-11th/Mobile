import 'dart:async';

import 'package:deku/core/storage/token_storage.dart';
import 'package:deku/data/models/favorite.dart';
import 'package:deku/data/models/tmdb_genre_dto.dart';
import 'package:deku/data/models/tmdb_movie_dto.dart';
import 'package:deku/data/models/tmdb_movie_page_dto.dart';
import 'package:deku/data/services/auth_api_service.dart';
import 'package:deku/data/services/favorite_api_service.dart';
import 'package:deku/data/services/member_api_service.dart';
import 'package:deku/data/services/tmdb_movie_service.dart';
import 'package:deku/view_models/auth_view_model.dart';
import 'package:deku/view_models/favorites_view_model.dart';
import 'package:deku/view_models/paged_movies_view_model.dart';
import 'package:deku/view_models/session_ratings_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v8 즐겨찾기 API는 movieId와 공통 응답을 사용한다', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://workbook.devnoco.com'));
    final calls = <String>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls.add('${options.method} ${options.path}');
          final result = switch ('${options.method} ${options.path}') {
            'GET /v8/favorites' => [
              {
                'favoriteId': 3,
                'movieId': 550,
                'createdAt': '2026-09-06T12:14:03Z',
              },
            ],
            'GET /v8/favorites/550' => {'isFavorite': true},
            'POST /v8/favorites' => {'favoriteId': 3, 'movieId': 550},
            _ => null,
          };
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: options.method == 'POST' ? 201 : 200,
              data: {
                'isSuccess': true,
                'code': 'COMMON200',
                'message': '성공',
                'result': result,
              },
            ),
          );
        },
      ),
    );
    final api = FavoriteApiService(dio);

    expect((await api.fetchFavorites()).single.movieId, 550);
    expect(await api.isFavorite(550), isTrue);
    expect((await api.addFavorite(550)).favoriteId, 3);
    await api.removeFavorite(550);
    expect(calls, [
      'GET /v8/favorites',
      'GET /v8/favorites/550',
      'POST /v8/favorites',
      'DELETE /v8/favorites/550',
    ]);
  });

  test('더 보기 실패 시 같은 page를 재시도하고 기존 영화를 유지한다', () async {
    final service = _MovieService()..failSecondPageOnce = true;
    final model = PagedMoviesViewModel(service);
    await model.loadFirst();
    expect(model.movies.map((movie) => movie.id), [1]);
    await model.loadMore();
    expect(model.loadMoreFailed, isTrue);
    expect(model.nextPage, 2);
    expect(model.movies.map((movie) => movie.id), [1]);
    await model.loadMore();
    expect(service.discoverPages, [1, 2, 2]);
    expect(model.movies.map((movie) => movie.id), [1, 2]);
    expect(model.hasMore, isFalse);
    model.dispose();
  });

  test('검색어를 바꾸면 늦은 이전 응답을 무시하고 빈 검색어는 요청하지 않는다', () async {
    final service = _MovieService();
    final old = Completer<TmdbMoviePageDto>();
    final current = Completer<TmdbMoviePageDto>();
    service.searchResults['old'] = old;
    service.searchResults['new'] = current;
    final model = PagedMoviesViewModel(service, mode: MoviePageMode.search);
    await model.submitSearch('  ');
    expect(service.searchQueries, isEmpty);
    final oldRequest = model.submitSearch('old');
    final newRequest = model.submitSearch('new');
    current.complete(_page(1, 1, [2]));
    await newRequest;
    old.complete(_page(1, 1, [1]));
    await oldRequest;
    expect(model.movies.map((movie) => movie.id), [2]);
    model.dispose();
  });

  test('TMDB 한 건 실패는 해당 카드만 실패로 남고 로그아웃하면 목록을 지운다', () async {
    final auth = AuthViewModel(
      AuthApiService(Dio()),
      MemberApiService(Dio()),
      _TokenStorage(),
      SessionRatingsStore(),
    )..status = AuthStatus.signedIn;
    final movies = _MovieService()..failingMovieId = 2;
    final model = FavoritesViewModel(_FavoriteService(), movies, auth);
    await model.refresh();
    expect(model.status, FavoritesStatus.success);
    expect(model.items, hasLength(2));
    expect(model.items.first.movie?.id, 1);
    expect(model.items.last.movieLoadFailed, isTrue);
    await auth.logout();
    expect(model.items, isEmpty);
    model.dispose();
    auth.dispose();
  });
}

TmdbMoviePageDto _page(int page, int totalPages, List<int> ids) =>
    TmdbMoviePageDto(
      page: page,
      totalPages: totalPages,
      results: ids.map((id) => TmdbMovieDto(id: id, title: '영화 $id')).toList(),
    );

class _MovieService implements MovieService {
  bool failSecondPageOnce = false;
  int? failingMovieId;
  final discoverPages = <int>[];
  final searchQueries = <String>[];
  final searchResults = <String, Completer<TmdbMoviePageDto>>{};

  @override
  Future<TmdbMoviePageDto> discoverMovies({int page = 1, int? genreId}) async {
    discoverPages.add(page);
    if (page == 2 && failSecondPageOnce) {
      failSecondPageOnce = false;
      throw StateError('network');
    }
    return _page(page, 2, [page]);
  }

  @override
  Future<TmdbMoviePageDto> searchMovies(String query, {int page = 1}) {
    searchQueries.add(query);
    return searchResults[query]!.future;
  }

  @override
  Future<TmdbMovieDto> fetchMovieById(int movieId) async {
    if (movieId == failingMovieId) throw StateError('TMDB');
    return TmdbMovieDto(id: movieId, title: '영화 $movieId');
  }

  @override
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async =>
      _page(1, 1, []);

  @override
  Future<List<TmdbGenreDto>> fetchGenres() async => const [];
}

class _FavoriteService extends FavoriteApiService {
  _FavoriteService() : super(Dio());

  @override
  Future<List<Favorite>> fetchFavorites() async => const [
    Favorite(favoriteId: 1, movieId: 1),
    Favorite(favoriteId: 2, movieId: 2),
  ];
}

class _TokenStorage implements TokenStorage {
  @override
  Future<void> deleteAccessToken() async {}
  @override
  Future<String?> readAccessToken() async => 'token';
  @override
  Future<void> saveAccessToken(String token) async {}
}
