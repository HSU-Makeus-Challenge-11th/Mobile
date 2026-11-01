import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movielog/data/models/tmdb_genre_dto.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

enum MovieListLoadStatus { idle, loading, success, empty, error }

/// 상태별 화면 확인용(디버그 모드 전용): 빈 목록·실패를 강제로 만든다
enum MovieListDebugMode { normal, empty, failure }

class MovieListViewModel extends ChangeNotifier {
  MovieListViewModel(this._service);
  final TmdbMovieService _service;

  static const maxMovies = 30;

  List<TmdbMovieDto> movies = const [];
  List<TmdbGenreDto> genres = const [];
  int? selectedGenreId;
  MovieListLoadStatus status = MovieListLoadStatus.idle;
  String? message;
  MovieListDebugMode debugMode = MovieListDebugMode.normal;

  int _requestVersion = 0;
  bool _disposed = false;

  bool get isLoading => status == MovieListLoadStatus.loading;

  /// 카드에 장르 이름을 보여 주기 위한 id → name 표
  Map<int, String> get genreNames => {
    for (final genre in genres) genre.id: genre.name,
  };

  Future<List<TmdbMovieDto>> fetchUpToThirtyMovies({int? genreId}) async {
    if (debugMode == MovieListDebugMode.empty) return const [];
    if (debugMode == MovieListDebugMode.failure) {
      throw DioException(
        requestOptions: RequestOptions(path: '/discover/movie'),
        message: '디버그 모드에서 강제로 실패시킨 요청',
      );
    }

    // TMDB id를 key로 써서 페이지 사이에 겹친 영화는 하나만 남긴다
    final byId = <int, TmdbMovieDto>{};
    var pageNumber = 1;
    var hasNextPage = true;

    while (byId.length < maxMovies && hasNextPage) {
      final page = await _service.discoverMovies(
        page: pageNumber,
        genreId: genreId,
      );

      for (final movie in page.results) {
        byId[movie.id] = movie;
        if (byId.length == maxMovies) break;
      }

      hasNextPage = pageNumber < page.totalPages && page.results.isNotEmpty;
      pageNumber++;
    }

    return byId.values.take(maxMovies).toList();
  }

  Future<void> loadInitial() async {
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      if (genres.isEmpty) genres = await _service.fetchGenres();
      final discovered = await fetchUpToThirtyMovies(genreId: selectedGenreId);

      if (_disposed || version != _requestVersion) return;
      movies = discovered;
      status = movies.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_disposed || version != _requestVersion) return;
      status = MovieListLoadStatus.error;
      message = '영화를 불러오지 못했어요. 다시 시도해 주세요.';
    }

    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  /// "전체"는 genreId: null로 요청해 with_genres를 보내지 않는다
  Future<void> selectGenre(int? genreId) async {
    // Discover 요청 중에는 장르를 바꾸지 못하게 막는다
    if (isLoading) return;
    selectedGenreId = genreId;
    final version = ++_requestVersion;
    status = MovieListLoadStatus.loading;
    message = null;
    notifyListeners();

    try {
      final result = await fetchUpToThirtyMovies(genreId: genreId);
      if (_disposed || version != _requestVersion) return;
      movies = result;
      status = result.isEmpty
          ? MovieListLoadStatus.empty
          : MovieListLoadStatus.success;
    } on DioException {
      if (_disposed || version != _requestVersion) return;
      status = MovieListLoadStatus.error;
      message = '해당 장르 영화를 불러오지 못했어요.';
    }

    if (!_disposed && version == _requestVersion) notifyListeners();
  }

  /// 다시 시도는 정상 모드로 같은 장르 조건을 page 1부터 다시 불러온다
  Future<void> retry() {
    debugMode = MovieListDebugMode.normal;
    return loadInitial();
  }

  Future<void> changeDebugMode(MovieListDebugMode mode) {
    debugMode = mode;
    return loadInitial();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}
